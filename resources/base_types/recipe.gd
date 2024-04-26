@static_unload
class_name Recipe
extends RefCounted

enum Category{
	MAIN,
	SIDE
}

enum Type{
	BURGER,
	FRIES
}

enum Constraints{
	MINIMUM_AMOUNT
}

static var recipes: Dictionary = {
	Type.BURGER : {
		Category : Category.MAIN, 
		Ingredient.Category : [Ingredient.Category.BURGER_PART], 
		Constraints.MINIMUM_AMOUNT : 3
		},
	Type.FRIES : {
		Category : Category.SIDE, 
		Ingredient.Category : [Ingredient.Category.FRIES]
		}
}

static var categories: Dictionary = {
	Category.MAIN : [Type.BURGER],
	Category.SIDE : [Type.FRIES]
}

var ingredients: Array[Ingredient.Type]


static func create_recipe(type: Type) -> Recipe:
	var new_recipe :=  Recipe.new()
	var min_amount := 1
	var possible_ingredients: Array[Ingredient.Type]
	
	# Check if this recipe type has the MINIMUM_AMOUNT constraint
	if recipes[type].has(Constraints.MINIMUM_AMOUNT):
		min_amount = recipes[type].get(Constraints.MINIMUM_AMOUNT)
	
	# gather all the ingredients that can be used for this type of recipe
	for ingredient_category in recipes[type][Ingredient.Category]:
		possible_ingredients += Ingredient.categories[ingredient_category].values()
	
	# take a random amount of ingredients
	var amount = randi_range(min_amount, possible_ingredients.size())
	
	# fill the ingredients array of the new recipe with random ingredients from the possible ingredients
	# take random elements from the pool of possible ingredients
	# currently an ingredient can only be taken once
	var used_ingredients: Array[Ingredient.Type]
	for i in range(amount):
		var ingr = possible_ingredients.pick_random()
		possible_ingredients.erase(ingr)
	
	
	var open_positions = range(amount)
	var used_ingredients_copy = used_ingredients.duplicate()
	for ingr in used_ingredients_copy:
		# check if this ingredient has a position constraint
		# if yes insert it at this position and mark that this position is already taken
		if Ingredient.ingredients[ingr].has(Ingredient.Constraints.POSITION):
			var position = Ingredient.ingredients[ingr][Ingredient.Constraints.POSITION]
			assert(new_recipe.ingredients[position] == null, "Recipe position is already taken")
			new_recipe.ingredients[position] = ingr
			used_ingredients.erase(ingr)
			if position > 0: 
				open_positions.remove_at(position)
			else:
				open_positions.remove_at(amount - (1+position))
	
	for pos in open_positions:
			assert(used_ingredients.size() > 0, "no more open positions")
			new_recipe.ingredients[pos] = used_ingredients.pop_back()
	
	return new_recipe
	
