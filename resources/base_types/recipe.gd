@static_unload
class_name Recipe
extends RefCounted

enum Category{
	MAIN,
	SIDE,
	DRINK
}

enum Type{
	BURGER,
	FRIES,
	DRINKS
}

enum Constraints{
	MINIMUM_AMOUNT,
	MAXIMUM_AMOUNT,
	MUST_HAVE
}

static var recipes: Dictionary = {
	Type.BURGER : {
		Category : Category.MAIN, 
		Ingredient.Category : [Ingredient.Category.BURGER_PART, Ingredient.Category.SAUCES], 
		Constraints.MINIMUM_AMOUNT : 3,
		Constraints.MUST_HAVE : [Ingredient.Type.BUN_BOTTOM, Ingredient.Type.PATTY, Ingredient.Type.BUN_TOP]
		},
	Type.FRIES : {
		Category : Category.SIDE, 
		Ingredient.Category : [Ingredient.Category.FRIES],
		Constraints.MAXIMUM_AMOUNT : 1,
		},
	Type.DRINKS : {
		Category : Category.DRINK,
		Ingredient.Category: [Ingredient.Category.DRINKS],
		Constraints.MAXIMUM_AMOUNT : 1,
	}
}

static var categories: Dictionary = {
	Category.MAIN : [Type.BURGER],
	Category.SIDE : [Type.FRIES],
	Category.DRINK : [Type.DRINKS]
}

var ingredients: Array[Ingredient.Type]
var type: Type

static func create_recipe(type: Type) -> Recipe:
	var new_recipe :=  Recipe.new()
	new_recipe.type = type
	var min_amount := 0
	var max_amount := INF
	var possible_ingredients: Array
	
	# gather all the ingredients that can be used for this type of recipe
	for ingredient_category in recipes[type][Ingredient.Category]:
		possible_ingredients += Ingredient.categories[ingredient_category]
	
	# Check if this recipe type has the MINIMUM_AMOUNT constraint
	if recipes[type].has(Constraints.MINIMUM_AMOUNT):
		min_amount = recipes[type].get(Constraints.MINIMUM_AMOUNT)
	# Check if this recipe type has the MAXIMUM_AMOUNT constraint
	if recipes[type].has(Constraints.MAXIMUM_AMOUNT):
		max_amount = recipes[type].get(Constraints.MAXIMUM_AMOUNT)
	else:
		max_amount = possible_ingredients.size() * 1.5
	
	# take a random amount of ingredients
	var amount = randi_range(min_amount, max_amount)
	new_recipe.ingredients.resize(amount)
	new_recipe.ingredients.fill(-1)
	
	
	# fill the ingredients array of the new recipe with random ingredients from the possible ingredients
	# take random elements from the pool of possible ingredients
	var used_ingredients: Array[Ingredient.Type]
	if(recipes[type].has(Constraints.MUST_HAVE)):
		for must_have in recipes[type][Constraints.MUST_HAVE]:
			var ingr
			if must_have is Array:
				ingr = must_have.pick_random()
			else:
				ingr = must_have
			used_ingredients.append(ingr)
			if(Ingredient.ingredients[ingr].has(Ingredient.Constraints.MAX_USE) and used_ingredients.count(ingr) >= Ingredient.ingredients[ingr][Ingredient.Constraints.MAX_USE]):
				possible_ingredients.erase(ingr)
	
	for i in range(amount):
		var ingr = possible_ingredients.pick_random()
		used_ingredients.append(ingr)
		if(Ingredient.ingredients[ingr].has(Ingredient.Constraints.MAX_USE) and used_ingredients.count(ingr) >= Ingredient.ingredients[ingr][Ingredient.Constraints.MAX_USE]):
			possible_ingredients.erase(ingr)
	
	
	var open_positions = range(amount)
	var used_ingredients_copy = used_ingredients.duplicate()
	for ingr in used_ingredients_copy:
		# check if this ingredient has a position constraint
		# if yes insert it at this position and mark that this position is already taken
		if Ingredient.ingredients[ingr].has(Ingredient.Constraints.POSITION):
			var position = Ingredient.ingredients[ingr][Ingredient.Constraints.POSITION]
			assert(new_recipe.ingredients.size() == 0 or new_recipe.ingredients[position] == -1, "Recipe position is already taken")
			new_recipe.ingredients[position] = ingr
			used_ingredients.erase(ingr)
			if position >= 0: 
				open_positions.erase(position)
			else:
				open_positions.erase(amount + position)
	
	for pos in open_positions:
			assert(used_ingredients.size() > 0, "no more open positions")
			new_recipe.ingredients[pos] = used_ingredients.pop_back()
	
	return new_recipe
	
