extends Node3D

@export var item_scene:PackedScene= preload("res://chese_test/chese.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	#Make instance
	var chese_instance = item_scene.instantiate()
	self.add_child(chese_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_exited(body):
	if(body.name == "Lettuce"):
		body.visible = true
		body = body as Food
	if(body and !body.has_left):
		body.has_left = true
		var item = item_scene.instantiate()
		add_child(item)
		item.global_position = body.initial_position
