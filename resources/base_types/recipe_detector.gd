extends ShapeCast3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		check_for_order(null)

func check_for_order(recipe: Recipe) -> bool:
	force_shapecast_update()
	if collision_result.size() > 0:# and get_collision_count() >= recipe.ingredients.size():
		print(collision_result)
		collision_result.sort_custom(func(a, b): return a["point"].y < b["point"].y)
		for res in collision_result:
			if (res["collider"] as Node3D).is_in_group("burger_part"):
				prints("path: ", res["collider"].scene_file_path)
		return false
	return false
		
