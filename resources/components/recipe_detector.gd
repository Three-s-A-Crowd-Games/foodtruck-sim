extends XRToolsSnapZone

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		var recipe: Recipe = Recipe.new()
		recipe.ingredients = [Ingredient.Type.BUN_BOTTOM, Ingredient.Type.PATTY, Ingredient.Type.BUN_TOP]
		print("correct? -> ",check_for_order(recipe))

func check_for_order(recipe: Recipe) -> bool:
	if not is_instance_valid(recipe):
		return false
		
	return _recursive_check(recipe.ingredients, 0, picked_up_object)
		
func _recursive_check(ingredients: Array[Ingredient.Type], index: int, object: Node3D) -> bool:
	if not is_instance_valid(object) or not object is Food:
		return false
	object = object as Food
	if not object.has_node("BurgerStackZone"):
		return ingredients[index] == object.type
	var stack_zone: BurgerStackZone = object.get_node("BurgerStackZone")
	index += 1
	return object.type == ingredients[index-1] and _recursive_check(ingredients, index, stack_zone.picked_up_object)
		
