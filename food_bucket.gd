extends StaticBody3D

const CUBE = preload("res://resources/cube.tscn")

@export var up_spawn_vector: Vector3

var can_spawn : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(number_touching)
	pass
	
func _on_full_area_body_exited(body):
	if(body.is_in_group("buns") && !body.has_left):
		body.has_left = true
		var cube = CUBE.instantiate()
		add_sibling(cube)
		cube.global_position = body.initial_pos
		print("LEFT")

