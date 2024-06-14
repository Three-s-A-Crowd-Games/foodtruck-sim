@tool
extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var node = Node3D.new()
	#var basis = Basis.FLIP_Y
	#node.transform.basis = basis
	node.rotate_z(PI)
	node.rotate_y(PI)
	
	add_child(node)
	
	printt(Vector3(0.25,0,0).rotated(Vector3.FORWARD, PI/2))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
