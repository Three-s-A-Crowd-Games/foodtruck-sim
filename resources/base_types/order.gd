class_name Order
extends RefCounted

const MIN_ORDER_TIME := 30
const MAX_ORDER_TIME := 60

var number :int

var main_recipe: Recipe
var side_recipe: Recipe
var drink_recipe: Recipe

var order_paper: OrderPaper

var time_left :float

signal out_of_time(order :Order)

func _process(delta :float) -> void:
	self.time_left -= delta
	if time_left <= 0:
		if is_instance_valid(order_paper):
			order_paper.queue_free()
		out_of_time.emit(self)

static func create_order(number :int) -> Order:
	var new_order = Order.new()
	new_order.number = number
	new_order.time_left = randf_range(MIN_ORDER_TIME, MAX_ORDER_TIME)
	new_order.main_recipe = Recipe.create_recipe(Recipe.categories[Recipe.Category.MAIN].pick_random())
	new_order.side_recipe = Recipe.create_recipe(Recipe.categories[Recipe.Category.SIDE].pick_random())
	new_order.drink_recipe = Recipe.create_recipe(Recipe.categories[Recipe.Category.DRINK].pick_random())
	return new_order
