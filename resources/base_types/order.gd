class_name Order
extends RefCounted

const MIN_ORDER_TIME := 20
const MAX_ORDER_TIME := 30

var number :int

var main_recipe: Recipe
var side_recipe: Recipe
var drink_recipe: Recipe

var tray :Tray
var order_paper: OrderPaper

var le_timer :Timer

signal out_of_time(order :Order)

func completed():
	le_timer.stop()
	if is_instance_valid(order_paper):
		order_paper.queue_free()
	
	if is_instance_valid(tray):
		var despawn_timer = Timer.new()
		despawn_timer.one_shot = true
		despawn_timer.wait_time = 5
		despawn_timer.timeout.connect(done)
		tray.add_child(despawn_timer)
		despawn_timer.start()

func done():
	if is_instance_valid(tray):
		tray.nuke()

func _on_timeout() -> void:
	print("Order",number," timed out")
	if is_instance_valid(order_paper):
		order_paper.queue_free()
	out_of_time.emit(self)

static func create_order(number :int) -> Order:
	var new_order = Order.new()
	new_order.number = number
	new_order.le_timer = Timer.new()
	new_order.le_timer.wait_time = randf_range(MIN_ORDER_TIME, MAX_ORDER_TIME)
	new_order.le_timer.one_shot = true
	new_order.le_timer.timeout.connect(new_order._on_timeout)
	OrderController.add_child(new_order.le_timer)
	new_order.le_timer.start()
	new_order.main_recipe = Recipe.create_recipe(Recipe.categories[Recipe.Category.MAIN].pick_random())
	new_order.side_recipe = Recipe.create_recipe(Recipe.categories[Recipe.Category.SIDE].pick_random())
	new_order.drink_recipe = Recipe.create_recipe(Recipe.categories[Recipe.Category.DRINK].pick_random())
	return new_order
