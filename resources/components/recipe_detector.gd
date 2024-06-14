extends XRToolsSnapZone

func check_for_recipe(recipe: Recipe) -> bool:
	if not is_instance_valid(recipe):
		return false

	return _recursive_check(recipe.ingredients, 0, picked_up_object)

func _recursive_check(ingredients: Array[Ingredient.Type], index: int, object: Food) -> bool:
	if not is_instance_valid(object):
		return false
	var stack_zone: XRToolsSnapZone = object.find_children("*", "XRToolsSnapZone", false, false)[0]
	
	if not stack_zone or not stack_zone.picked_up_object:
		if index == ingredients.size() - 1:
			return ingredients[index] == object.type
		else:
			return false
	index += 1
	if object.type != ingredients[index-1]:
		return false
	else:
		return _recursive_check(ingredients, index, stack_zone.picked_up_object)
