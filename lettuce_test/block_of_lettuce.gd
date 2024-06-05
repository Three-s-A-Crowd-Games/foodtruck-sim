extends Node3D


@export var item_scene:PackedScene= preload("res://lettuce_test/lettuce.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	#Make instance
	var letuce_instance = item_scene.instantiate()
	self.add_child(letuce_instance)


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
		
		
		
			
		
		
		
			
		
		
