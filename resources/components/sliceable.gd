@tool
class_name Sliceable
extends Area3D

# Constraint: Sliceable objects only get shorter in their x direction from positiv to negativ
#TODO: When the sliceable is facing downwards the slice might spawn beneath the ground an fall through

var slice_thread :Thread
var mutex := Mutex.new()

var original_width: float
var original_height: float
var original_depth: float
var slice_positions: Array[float]
var slices_left: int
var slice_width: float
var slice_scene: PackedScene = preload("res://resources/base_types/burger_part.tscn")
var _flip_factor: int
var _mesh_node: MeshInstance3D
var _inverse_mesh_basis: Basis
var _is_mesh_ontop_xz := false
@export var cross_section_material: Material
@export var slice_spawn_seperation_distance := 0.02
## Select how many slices the object will produce. But be sure to set it high enaugh so the slices won't be to big.
@export var slice_count := 3 :
	set(value):
		slice_count = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

@export var slice_mass := 0.1

## Select the mesh node which should be sliced or its parent node.
@export var _mesh_node_or_parent: Node3D:
	set(value):
		_mesh_node_or_parent = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

## The type of shape that will be used for the remaining foods collision shape after was cut.
@export_enum("CylinderShape3D", "BoxShape3D") var remain_shape: String = "CylinderShape3D"

@export_group("Mesh Deletion")
## Select a second mesh node which should be deleted while slicing.
@export var mesh_node_to_delete: MeshInstance3D
## Select with which slice action the second mesh should be deleted.
@export var delete_slice_count: int = 1

@export_group("Sound")
@export_enum("Normal", "Crunchy") var slice_sound_type := "Normal"
var hard_soft_sound_threshold: float = 3
@onready var hard_player: SoundQueue3D = $SoundQueue3DHard
@onready var soft_player: SoundQueue3D = $SoundQueue3DSoft

@onready var _sliceable := get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	slice_thread = Thread.new()
	mutex = Mutex.new()
	
	if _mesh_node_or_parent is MeshInstance3D:
		_mesh_node = _mesh_node_or_parent
	else:
		_mesh_node = _mesh_node_or_parent.find_children("*", "MeshInstance3D", false)[0]
	
	assert(_mesh_node != null, "No mesh node could be found for slicing")
	_inverse_mesh_basis = _mesh_node.transform.inverse().basis
	
	#Copy the collision shape node of the parent
	if find_children("*", "CollisionShape3D", false).size() == 0:
		var my_coll_node:CollisionShape3D = get_parent().find_children("*", "CollisionShape3D", false)[0].duplicate()
		# WARNING: Very dirty way to determine whether the mesh of the sliceable object is not centered in around the mesh node.
		if my_coll_node.position.y != _mesh_node.position.y: _is_mesh_ontop_xz = true
		my_coll_node.transform.origin -= transform.origin
		add_child(my_coll_node)
	
	get_parent().has_left_spawn.connect(_on_has_left_spawn)
	
	body_entered.connect(_on_body_entered)
	if Engine.is_editor_hint():
		child_entered_tree.connect(_updated_children)
		child_exiting_tree.connect(_updated_children)
	
	slices_left = slice_count
	
	var mesh_node_y_angle := _mesh_node.transform.basis.y.angle_to(Vector3.UP)
	
	var aabb = _mesh_node.mesh.get_aabb()
	original_width = sin(mesh_node_y_angle) * aabb.size.y + cos(mesh_node_y_angle) * aabb.size.x
	original_height = cos(mesh_node_y_angle) * aabb.size.y + sin(mesh_node_y_angle) * aabb.size.x
	original_depth = aabb.size.z
	slice_width = original_width / slice_count
	for i in range(1,slice_count):
		slice_positions.push_back(original_width/2 - slice_width * i)
		
	collision_layer = 0
	collision_mask = pow(2,5) # Mask layer 6
	monitorable = false
	 
	#Take care about audio setup
	for player: AudioStreamPlayer3D in $SoundQueue3DHard.get_children():
		match slice_sound_type:
			"Normal":
				player.stream = load("res://audio/slicing/normal/slice_normal_hard_audio_stream_randomizer.tres")
			"Crunchy":
				player.stream = load("res://audio/slicing/crunchy/slice_crunchy_hard_audio_stream_randomizer.tres")
						
	for player: AudioStreamPlayer3D in $SoundQueue3DSoft.get_children():
		match slice_sound_type:
			"Normal":
				player.stream = load("res://audio/slicing/normal/slice_normal_soft_audio_stream_randomizer.tres")
			"Crunchy":
				player.stream = load("res://audio/slicing/crunchy/slice_crunchy_soft_audio_stream_randomizer.tres")
				

func _on_body_entered(body):
	slice_thread.start(slice,Thread.PRIORITY_HIGH)
	if body is RigidBody3D:
		if body is XRToolsPickable and body.is_picked_up():
			soft_player.play()
			return
		if body.linear_velocity.length() > hard_soft_sound_threshold:
			hard_player.play()
		else:
			soft_player.play()
	else:
		soft_player.play()


func slice():
	mutex.lock()
	if slices_left <= 1: return
	mutex.unlock()
	
	var trans := _get_slice_transform()
	var meshes = MeshSlicer.slice_mesh(trans, _mesh_node.mesh, cross_section_material)
	call_deferred("slice_rest",meshes)
	slice_thread.call_deferred("wait_to_finish")

func slice_rest(meshes):
	slices_left -= 1
	_mesh_node.mesh = meshes[0]
	_adjust_collision_shape(_sliceable, meshes[0])
	call_deferred("_adjust_collision_shape", self, meshes[0])
	var slice := _create_slice(meshes[1])
	_sliceable.add_sibling(slice)
	_make_slice_ready(slice)
	
	if slice_count - slices_left == delete_slice_count and mesh_node_to_delete:
		mesh_node_to_delete.queue_free()
		
	if slices_left == 1:
		slice = _create_slice(meshes[0])
		_sliceable.add_sibling(slice)
		_make_slice_ready(slice)
		get_parent_node_3d().visible = false
		if hard_player.count_playing > 0:
			await hard_player.finished
		if soft_player.count_playing > 0:
			await soft_player.finished
		get_parent().call_deferred("queue_free")
	

## This method sets up some properties of the slice
## and hereby overrides the values calculated by the ready mehtod in BurgerPart.gd
func _make_slice_ready(slice: BurgerPart) -> void:
	slice.height = slice_width
	slice.stack_zone_distance = slice_width + slice.burger_part_seperation_distance
	slice.stack_zone.position.y = slice.stack_zone_distance
	slice.stack_zone.get_node("CollisionShape3D").shape.radius = original_height/2
	slice.mass = slice_mass
	slice.original_mass = slice_mass
	slice.center_of_mass = Vector3(0, slice_width/2, 0)
	slice.original_center_of_mass = Vector3(0, slice_width/2, 0)

func _get_slice_transform() -> Transform3D:
	# As far as I know the mesh slicing tool cuts along the xy-plane of the given transform.
	# The transform has to be in the local space of the mesh node.
	var trans := Transform3D.IDENTITY.rotated(Vector3.UP, PI/2)
	trans.basis = _mesh_node.transform.basis * trans.basis
	var angle = _mesh_node.transform.basis.y.signed_angle_to(Vector3.UP, Vector3.BACK)
	_flip_factor = 1 if angle == 0 else sign(angle)
	trans.origin.x = slice_positions[slice_count - slices_left] * _flip_factor
	trans.origin *= _inverse_mesh_basis
	trans.basis.z *= _flip_factor
	return trans
	

func _create_slice(mesh: Mesh) -> BurgerPart:
	var slice: BurgerPart = slice_scene.instantiate()
	slice.transform = _sliceable.transform
	slice.transform.origin += slice.basis.x * (slice_width+slice_spawn_seperation_distance) * (slices_left +1)
	slice.position.y = original_height/2 + 0.02 + _sliceable.position.y
	slice.rotate_z(7*PI/20)
	
	var mesh_node := _find_mesh_child_node(slice)
	if not mesh_node:
		mesh_node = MeshInstance3D.new()
		mesh_node.transform.basis = _inverse_mesh_basis
		slice.add_child(mesh_node)
	mesh_node.mesh = mesh
	
	var coll_node: CollisionShape3D = slice.get_node_or_null("CollisionShape3D")
	if not coll_node:
		coll_node = CollisionShape3D.new()
		slice.add_child(coll_node)
	_adjust_collision_shape(coll_node, mesh)
	
	_position_child_nodes(mesh_node, coll_node)
	
	var s := slice.get_node_or_null("Sliceable")
	if s:
		slice.remove_child(s)
		s.queue_free()
	
	slice.freeze = false
	return slice
	

func _position_child_nodes(mesh_node: MeshInstance3D, coll_node: CollisionShape3D) -> void:
	mesh_node.rotate_z(PI/2)
	
	var shift: Vector3
	# This shift is necessary because the mesh vertices created by the slicing are not always centered.
	# They are relative to the original node's origin.
	if slice_count % 2 == 0:
		shift.y = slice_width * (ceil(slice_count/2.0) - (slices_left+1) + 0.5+0.5*_flip_factor) * _flip_factor
	else:
		shift.y = slice_width * (ceil(slice_count/2.0) - (slices_left+1) + 0.5*_flip_factor) * _flip_factor
	
	shift.x = original_height/2 if _is_mesh_ontop_xz else 0
	
	mesh_node.position += shift
	coll_node.position.y = coll_node.shape.height/2
	

func _find_mesh_child_node(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D: return node
	
	if node.get_child_count() > 0:
		for child in node.get_children(true):
			var cc = _find_mesh_child_node(child)
			if cc is MeshInstance3D: return cc
	
	return null

func _adjust_collision_shape(node: Node, mesh: Mesh) -> void:
	var coll_node:CollisionShape3D = node if node is CollisionShape3D else node.get_node_or_null("CollisionShape3D")
	if coll_node:
		
		if node == self or node == _sliceable:
			match remain_shape:
				"CylinderShape3D":
					if not coll_node.shape is CylinderShape3D: coll_node.shape = CylinderShape3D.new()
					coll_node.shape.radius = original_height/2
					coll_node.shape.height = slices_left * slice_width
					coll_node.transform.basis = Basis(Vector3.BACK, PI/2)
				"BoxShape3D":
					if not coll_node.shape is BoxShape3D: coll_node.shape = BoxShape3D.new()
					coll_node.shape.size.x = slices_left * slice_width
					coll_node.shape.size.y = original_height
					coll_node.shape.size.z = original_depth
					coll_node.transform.basis = Basis.IDENTITY
			
			coll_node.position.x = -1 * slice_width/2.0 * (slice_count-slices_left)
		else:
			if not coll_node.shape is CylinderShape3D: coll_node.shape = CylinderShape3D.new()
			coll_node.shape.radius = original_height/2
			coll_node.shape.height = slice_width
	

func _updated_children(node: Node) -> void:
	update_configuration_warnings()

func _get_configuration_warnings():
	var out: Array[String] = []
	var has_coll_shape: bool = false
	for child in get_children():
		has_coll_shape = child is CollisionShape3D
	if not has_coll_shape:
		out.push_back("If it appears, you can ignore the warining about the missing collision shape for this area. It will take the collision shape of the parent then.")
	if not _mesh_node_or_parent:
		out.push_back("Mesh node is not configured. Please select the mesh node with the mesh that shall be sliced.")
	if slice_count == 4:
		out.push_back("Please don't use 4 slices. For some unkown reason the tool doesn't work properly then.")
	
	return out

func _on_has_left_spawn():
	monitoring = true

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	slice_thread.wait_to_finish()
