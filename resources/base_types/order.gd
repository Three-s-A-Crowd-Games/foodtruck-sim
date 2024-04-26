class_name Order
extends RefCounted

var main_recipe: Recipe
var side_recipe: Recipe

static func create_order() -> Order:
	var new_order = Order.new()
	new_order.main_recipe = Recipe.create_recipe(Recipe.categories[Recipe.Category.MAIN].pick_random())
	new_order.main_recipe = Recipe.create_recipe(Recipe.categories[Recipe.Category.SIDE].pick_random())
	return new_order
