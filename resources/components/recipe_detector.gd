extends XRToolsSnapZone

func check_for_recipe(recipe: Recipe) -> bool:
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
		
