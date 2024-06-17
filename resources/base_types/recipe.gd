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
	var max_amount := 12
	var possible_ingredients: Array
	
	# gather all the ingredients that can be used for this type of recipe
	for ingredient_category in recipes[type][Ingredient.Category]:
		possible_ingredients += Ingredient.categories[ingredient_category][Ingredient.Type]
	
	# Check if this recipe type has the MINIMUM_AMOUNT constraint
	if recipes[type].has(Constraints.MINIMUM_AMOUNT):
		min_amount = recipes[type].get(Constraints.MINIMUM_AMOUNT)
	# Check if this recipe type has the MAXIMUM_AMOUNT constraint
	if recipes[type].has(Constraints.MAXIMUM_AMOUNT):
		max_amount = recipes[type].get(Constraints.MAXIMUM_AMOUNT)
	
	# take a random amount of ingredients
	var amount = randi_range(min_amount, max_amount)
	var compl_amount = amount
	#free_moving_amount is important for double stacking -> tells us how many movable objects there are
	var free_moving_amount = amount
	new_recipe.ingredients.resize(amount)
	new_recipe.ingredients.fill(-1)
	
	
	# fill the ingredients array of the new recipe with random ingredients from the possible ingredients
	# take random elements from the pool of possible ingredients
	var used_ingredients: Array[Ingredient.Type]
	var open_positions = range(amount)
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
				#Lets see if it is immobile
				if(Ingredient.ingredients[ingr].has(Ingredient.Constraints.POSITION)):
					free_moving_amount -= 1
			amount -= 1
	
	var no_double_stack_amount = free_moving_amount/2
	if free_moving_amount%2 != 0:
		no_double_stack_amount += 1
	for i in range(amount):
		var ingr = possible_ingredients.pick_random()
		used_ingredients.append(ingr)
		# Handle Max_Amount
		if(Ingredient.ingredients[ingr].has(Ingredient.Constraints.MAX_USE) and used_ingredients.count(ingr) >= Ingredient.ingredients[ingr][Ingredient.Constraints.MAX_USE]):
			possible_ingredients.erase(ingr)
		# Handle No_Double_Stack (make sure there's not more of the category in there then we are able to sort without double stacking)
		if(Ingredient.categories[Ingredient.ingredients[ingr][Ingredient.Category]].has(Ingredient.Constraints.NO_DOUBLE_STACK) and get_amount_of_category(used_ingredients, Ingredient.ingredients[ingr][Ingredient.Category]) >= no_double_stack_amount):
			# Remove all ingredients of that category
			for pos_ingr in possible_ingredients:
				if Ingredient.ingredients[pos_ingr][Ingredient.Category] == Ingredient.ingredients[ingr][Ingredient.Category]:
					possible_ingredients.erase(pos_ingr)
	
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
				open_positions.erase(compl_amount + position)
	
	#Semi-Randomly place all other ingredients
	var all_placed = false
	while(!all_placed):
		all_placed = true
		var placed_ingredients = new_recipe.ingredients.duplicate()
		var open_positions_dub = open_positions.duplicate()
		for ingr in used_ingredients:
			var pos = open_positions_dub.pick_random()
			
			var ingr_cat = Ingredient.ingredients[ingr][Ingredient.Category]
			#Lets make sure that we value NO_DOUBLE_STACKS
			if(Ingredient.categories[ingr_cat].has(Ingredient.Constraints.NO_DOUBLE_STACK)):
				# Check if infront and behind are ok:
				# Either first/last one OR it's empty OR it's not of the same category
				var infront_okay = pos == 0 or placed_ingredients[pos-1] == -1 or ingr_cat != Ingredient.ingredients[placed_ingredients[pos-1]][Ingredient.Category]
				var behind_okay = pos == compl_amount - 1 or placed_ingredients[pos+1] == -1 or ingr_cat != Ingredient.ingredients[placed_ingredients[pos+1]][Ingredient.Category]
				# If this pos is not okay check if any open position is okay
				if(!infront_okay or !behind_okay):
					all_placed = false
					for inner_check_pos in open_positions_dub:
						infront_okay = inner_check_pos == 0 or ingr_cat != Ingredient.ingredients[placed_ingredients[inner_check_pos-1]][Ingredient.Category]
						behind_okay = inner_check_pos == compl_amount - 1 or ingr_cat != Ingredient.ingredients[placed_ingredients[inner_check_pos+1]][Ingredient.Category]
						if infront_okay and behind_okay:
							# Found good Pos
							all_placed = true
							pos = inner_check_pos
							break
				if !all_placed:
					# Try again
					break
			
			placed_ingredients[pos] = ingr
			open_positions_dub.erase(pos)
		new_recipe.ingredients = placed_ingredients
	
	return new_recipe
	
static func get_amount_of_category(ingr_list :Array, cat :Ingredient.Category) -> int:
	var count = 0
	for ingr in ingr_list:
		if Ingredient.ingredients[ingr][Ingredient.Category] == cat:
			count += 1
	return count
