class_name Order
extends RefCounted

var number :int

var main_recipe: Recipe
var side_recipe: Recipe
var drink_recipe: Recipe

static func create_order() -> Order:
	var new_order = Order.new()
	new_order.number = OrderController.get_next_num()
	new_order.main_recipe = Recipe.create_recipe(Recipe.categories[Recipe.Category.MAIN].pick_random())
	new_order.side_recipe = Recipe.create_recipe(Recipe.categories[Recipe.Category.SIDE].pick_random())
	new_order.drink_recipe = Recipe.create_recipe(Recipe.categories[Recipe.Category.DRINK].pick_random())
	return new_order
