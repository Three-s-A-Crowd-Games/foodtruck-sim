extends MeshInstance3D

const CUBE = preload("res://resources/cube.tscn")

@export var up_spawn_vector: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_key_pressed(KEY_P)):
		var cube = CUBE.instantiate()
		add_sibling(cube)
		cube.position= position + up_spawn_vector


func _on_area_3d_body_entered(body):
	if(body.name=="PokeBody"):
		var cube = CUBE.instantiate()
		add_sibling(cube)
		cube.position= position + up_spawn_vector

