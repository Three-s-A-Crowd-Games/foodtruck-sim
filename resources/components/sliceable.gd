@tool
class_name Sliceable
extends Area3D

# Constraint: Sliceable objects only get shorter in their x direction from positiv to negativ

var original_width: float
var slice_positions: Array[float]
var slices_left: int
var slice_width: float
var slice_scene: PackedScene = preload("res://resources/base_types/burger_part.tscn")
var _flip_factor: int
var _mesh_node: MeshInstance3D
var _inverse_mesh_transform: Transform3D
@export var cross_section_material: Material
@export var slice_spawn_seperation_distance := 0.2
@export var slice_count := 3 :
	set(value):
		slice_count = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Select the mesh node which should be sliced or its parent node.
@export var _mesh_node_or_parent: Node3D:
	set(value):
		_mesh_node_or_parent = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

@export_category("Mesh Deletion")
## Select a second mesh node which should be deleted while slicing.
@export var mesh_node_to_delete: MeshInstance3D
## Select with which slice action the second mesh should be deleted.
@export var delete_slice_count: int = 1

@onready var _sliceable := get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	if _mesh_node_or_parent is MeshInstance3D:
		_mesh_node = _mesh_node_or_parent
	else:
		_mesh_node = _mesh_node_or_parent.find_children("*", "MeshInstance3D", false)[0]
	
	assert(_mesh_node != null, "No mesh node could be found for slicing")
	_inverse_mesh_transform = _mesh_node.transform.inverse()
	
	if find_children("*", "CollisionShape3D", false).size() == 0:
		add_child(get_parent().find_children("*", "CollisionShape3D", false)[0].duplicate())
	
	body_entered.connect(_on_body_entered)
	child_entered_tree.connect(update_configuration_warnings)
	child_exiting_tree.connect(update_configuration_warnings)
	
	slices_left = slice_count
	
	var mesh_node_y_angle := _mesh_node.transform.basis.y.angle_to(Vector3.UP)
	
	var col_shape = _sliceable.get_node("CollisionShape3D").shape
	if col_shape is SphereShape3D:
		original_width = col_shape.radius * 2
	elif col_shape is CylinderShape3D or col_shape is CapsuleShape3D:
		original_width = sin(mesh_node_y_angle) * col_shape.height + cos(mesh_node_y_angle) * col_shape.radius * 2
	elif col_shape is BoxShape3D:
		original_width = sin(mesh_node_y_angle) * col_shape.size.x + cos(mesh_node_y_angle) * col_shape.size.y
	else:
		push_error("Collsion shape of sliceable ", _sliceable, " isn't compatible with slicing. Use sphere, cylinder, capsule or box shape")
		assert(false, "Collsion shape of sliceable " + str(_sliceable) + " isn't compatible with slicing. Use sphere, cylinder, capsule or box shape")
		
	slice_width = original_width / slice_count
	for i in range(1,slice_count):
		slice_positions.push_back(original_width/2 - slice_width * i)
		
	collision_layer = 0
	collision_mask = pow(2,5) # Mask layer 6
	monitorable = false
	 

func _on_body_entered(body):
	slice()

func slice():
	if slices_left <= 1: return
	
	var trans := _get_slice_transform()
	var meshes := MeshSlicer.slice_mesh(trans, _mesh_node.mesh, cross_section_material)
	_mesh_node.mesh = meshes[0]
	_adjust_collision_shape(_sliceable, meshes[0])
	call_deferred("_adjust_collision_shape", self, meshes[0])
	_sliceable.add_sibling(_create_slice(meshes[1]))
	slices_left -= 1
	
	if slice_count - slices_left == delete_slice_count and mesh_node_to_delete:
		mesh_node_to_delete.queue_free()
		
	if slices_left == 1:
		_sliceable.add_sibling(_create_slice(meshes[1]))
		get_parent().call_deferred("queue_free")
	#TODO: last pice is off center
	#TODO: configure the burger stack zone scene properly
	#TODO: When the sliceable is facing downwards the slice might spawn beneath the ground an fall through

func _get_slice_transform() -> Transform3D:
	# As far as I know the mesh slicing tool cuts along the xy-surface of the given transform.
	# The transform has to be in the local space of the mesh node.
	var trans := Transform3D.IDENTITY.rotated(Vector3.UP, PI/2)
	trans = _mesh_node.transform * trans
	var angle = _mesh_node.transform.basis.y.signed_angle_to(Vector3.UP, Vector3.BACK)
	_flip_factor = 1 if angle == 0 else sign(angle)
	trans.origin.x = slice_positions[slice_count - slices_left] * _flip_factor
	trans.origin *= _inverse_mesh_transform
	trans.basis.z *= _flip_factor
	return trans
	

func _create_slice(mesh: Mesh) -> BurgerPart:
	var slice: BurgerPart = slice_scene.instantiate()
	slice.transform = _sliceable.transform
	slice.transform.origin += slice.basis.x * (slice_width+slice_spawn_seperation_distance) * slices_left
	slice.position.y += 0.02
	slice.rotate_z(7*PI/20)
	
	var mesh_node := _find_mesh_child_node(slice)
	if not mesh_node:
		mesh_node = MeshInstance3D.new()
		mesh_node.transform = _inverse_mesh_transform
		slice.add_child(mesh_node)
	mesh_node.mesh = mesh
	
	var coll_node = slice.get_node_or_null("CollisionShape3D")
	if not coll_node:
		coll_node = CollisionShape3D.new()
		slice.add_child(coll_node)
	_adjust_collision_shape(coll_node, mesh)
	coll_node.transform = _inverse_mesh_transform
	
	_position_child_nodes(mesh_node, coll_node, slice.get_node("BurgerStackZone"))
	
	var s := slice.get_node_or_null("Sliceable")
	if s:
		slice.remove_child(s)
		s.queue_free()
	
	return slice
	

func _position_child_nodes(mesh_node: MeshInstance3D, coll_node: CollisionShape3D, stack_zone: BurgerStackZone) -> void:
	mesh_node.rotate_z(PI/2)
	coll_node.rotate_z(PI/2)
	
	if slices_left == 1: slices_left = 2
	var shift: float
	# This shift is necessary because the mesh vertices created by the slicing are not always centered
	if slice_count % 2 == 0:
		shift = slice_width * (ceil(slice_count/2.0) - slices_left + 0.5) * _flip_factor
	else:
		shift = slice_width * (ceil(slice_count/2.0) - slices_left) * _flip_factor
		
	mesh_node.position.y += shift
	coll_node.position.y += shift
	stack_zone.position.y += (slice_width/2 + stack_zone.grab_distance + 0.1)
	

func _find_mesh_child_node(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D: return node
	
	if node.get_child_count() > 0:
		for child in node.get_children(true):
			var cc = _find_mesh_child_node(child)
			if cc is MeshInstance3D: return cc
	
	return null

func _adjust_collision_shape(node: Node, mesh: Mesh) -> void:
	var coll_node = node if node is CollisionShape3D else node.get_node_or_null("CollisionShape3D")
	if coll_node:
		coll_node.shape = mesh.create_convex_shape()
	


func _get_configuration_warnings():
	var out: Array[String] = []
	if get_child_count() == 0:
		out.push_back("If it appears, you can ignore the warining about the missing collision shape for this area. It will take the collision shape of the parent then.")
	if not _mesh_node:
		out.push_back("Mesh node is not configured. Please select the mesh node with the mesh that shall be sliced.")
	if slice_count == 4:
		out.push_back("Please don't use 4 slices. For some unkown reason the tool doesn't work properly then.")
	
	return out
