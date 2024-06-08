extends Node3D

@export var item_scene:PackedScene = preload("res://resources/test_helpers/cube.tscn")


func _on_exit_detector_body_exited(body):
	body = body as Food
	if(body and !body.has_left_spawner):
		body.has_left_spawner = true
		var item = item_scene.instantiate()
		add_child(item)
		item.global_position = body.position_before_pickup
