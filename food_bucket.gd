extends StaticBody3D

const CUBE = preload("res://resources/cube.tscn")

@export var up_spawn_vector: Vector3

var can_spawn : bool = true

var number_touching : int
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(number_touching)
	pass


func _on_area_3d_body_entered(body):
	if(body.name=="PokeBody" && number_touching <= 0):
		var cube = CUBE.instantiate()
		add_sibling(cube)
		cube.position= position + up_spawn_vector


func _on_full_area_body_entered(body):
	if(body.is_in_group("buns")):
		number_touching += 1
		


func _on_full_area_body_exited(body):
	if(body.is_in_group("buns")):
		number_touching -= 1
