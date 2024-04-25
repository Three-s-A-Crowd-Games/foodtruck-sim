extends Node3D

@export var item_scene:PackedScene = preload("res://resources/cube.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _on_exit_detector_body_exited(body):
	body = body as Food
	if(body and !body.has_left):
		body.has_left = true
		var item = item_scene.instantiate()
		add_sibling(item)
		item.global_position = body.initial_position

