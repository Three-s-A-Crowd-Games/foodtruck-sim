extends XRToolsSnapZone

func check_for_recipe(recipe: Recipe) -> bool:
	if not is_instance_valid(recipe) or not is_instance_valid(picked_up_object): return false
	if not picked_up_object is Food: return false
	
	if recipe.type == Recipe.Type.BURGER:
		if not picked_up_object is BurgerPart: return false
		for i in picked_up_object.burger_part_stack.size():
			if picked_up_object.burger_part_stack[i].type != recipe.ingredients[i]:
				return false
		return true
	
	return picked_up_object.type == recipe.ingredients[0]
	
