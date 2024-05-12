class_name Sliceable
extends Area3D

var original_width: float
var slice_positions: Array[float]
var slices_left: int
var slice_width: float
@export var slice_scene: PackedScene = preload("res://resources/cube2.tscn")
@export var slice_count := 2
@onready var sliceable := get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	
	slices_left = slice_count
	var col_shape = sliceable.get_node("CollisionShape3D").shape
	if col_shape is SphereShape3D or col_shape is CylinderShape3D or col_shape is CapsuleShape3D:
		original_width = col_shape.radius * 2
	elif col_shape is BoxShape3D:
		original_width = col_shape.size.x
	else:
		push_error("Collsion shape of sliceable ", sliceable, " isn't compatible with slicing. Use sphere, cylinder, capsule or box shape")
		
	slice_width = original_width / slice_count
	for i in range(1,slice_count):
		slice_positions.push_back(original_width/2 - slice_width * i)

func _on_body_entered(body):
	slice()
	print("EEEEEE")

func slice():
	if slices_left <= 1: return
	
	var trans = get_slice_transform()
	var sliceable_mesh: MeshInstance3D = _find_mesh_child_node(sliceable)
	var meshes = MeshSlicer.slice_mesh(trans, sliceable_mesh.mesh)
	sliceable_mesh.mesh = meshes[0]
	_adjust_collision_shape(sliceable, meshes[0])
	call_deferred("_adjust_collision_shape", self, meshes[0])
	sliceable.add_sibling(_create_slice(meshes[1], trans))
	slices_left -= 1
	
	#TODO: attach burger stack zones to the slices
	

func get_slice_transform() -> Transform3D:
	var trans: Transform3D = sliceable.transform
	trans.origin = sliceable.to_local(trans.origin)
	trans.basis.x = sliceable.to_local(trans.basis.x + sliceable.global_position)
	trans.basis.y = sliceable.to_local(trans.basis.y + sliceable.global_position)
	trans.basis.z = sliceable.to_local(trans.basis.z + sliceable.global_position)
	trans = trans.rotated(Vector3.UP, PI/2)
	trans.origin.x = slice_positions[slice_count - slices_left]
	return trans

func _create_slice(mesh: Mesh, trans: Transform3D) -> Node:
	var slice: Node = slice_scene.instantiate()
	
	var mesh_node = _find_mesh_child_node(slice)
	if not mesh_node:
		mesh_node = MeshInstance3D.new()
		slice.add_child(mesh_node)
	mesh_node.mesh = mesh
	
	_adjust_collision_shape(slice, mesh)
	
	slice.transform = sliceable.transform
	slice.transform.origin += slice.basis.x * slice_width * slices_left
	
	var s = slice.get_node_or_null("Sliceable")
	if s:
		slice.remove_child(s)
		s.queue_free()
	
	return slice

func _find_mesh_child_node(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D: return node
	
	if node.get_child_count() > 0:
		for child in node.get_children(true):
			var cc = _find_mesh_child_node(child)
			if cc is MeshInstance3D: return cc
	
	return null

func _adjust_collision_shape(node: Node, mesh: Mesh) -> void:
	var collision_shape_node = node.get_node_or_null("CollisionShape3D")
	if collision_shape_node:
		collision_shape_node.shape = mesh.create_convex_shape()
