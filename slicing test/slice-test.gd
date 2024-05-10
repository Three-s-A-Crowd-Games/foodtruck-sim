extends Node3D

var slicer = MeshSlicer.new()
@onready var cube: Cube = $Cube

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		var trans = Transform3D.IDENTITY
		trans.origin = cube.slice_positions[cube.slice_count - cube.slices_left]
		trans = trans.rotated(Vector3.UP, PI/2)
		cube.slices_left -= 1
		
		var cube_mesh = cube.get_node("MeshInstance3D")
		
		var meshes = slicer.slice_mesh(trans, cube_mesh.mesh)
		
		cube_mesh.mesh = meshes[0]
		cube.get_node("CollisionShape3D").shape = meshes[0].create_convex_shape()
		
		var cube2 := cube.duplicate()
		
		cube2.get_node("MeshInstance3D").mesh = meshes[1]
		cube2.get_node("CollisionShape3D").shape = meshes[1].create_convex_shape()
		cube2.global_position = cube.global_position + Vector3(cube.original_width,0,0)
		#cube.to_global(trans.origin + Vector3(cube.slice_width,0,0))
		add_child(cube2)
		
