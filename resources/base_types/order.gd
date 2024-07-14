class_name Order
extends RefCounted

signal order_time_low

# After which size they are considered what type of order
const S_MAIN_ORDER := 3
const M_MAIN_ORDER := 5
const L_MAIN_ORDER := 8

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

func _on_timeout() -> void:
	print("Order",number," timed out")
	if is_instance_valid(order_paper):
		order_paper.queue_free()
	out_of_time.emit(self)

static func create_order(number :int) -> Order:
	var new_order = Order.new()
	new_order.number = number
	new_order.le_timer = Timer.new()
	new_order.le_timer.one_shot = true
	new_order.le_timer.timeout.connect(new_order._on_timeout)
	OrderController.add_child(new_order.le_timer)
	new_order.main_recipe = Recipe.create_recipe(Recipe.categories[Recipe.Category.MAIN].pick_random())
	new_order.side_recipe = Recipe.create_recipe(Recipe.categories[Recipe.Category.SIDE].pick_random())
	new_order.drink_recipe = Recipe.create_recipe(Recipe.categories[Recipe.Category.DRINK].pick_random())
	
	# Calculate Order-Time
	var calc_wait_time = 0
	if new_order.drink_recipe.ingredients.size() > 0:
		calc_wait_time += 100
	if new_order.side_recipe.ingredients.size() > 0:
		calc_wait_time += 200
	calc_wait_time += get_main_wait(new_order.main_recipe.ingredients.size())
	
	new_order.le_timer.wait_time = calc_wait_time
	new_order.le_timer.start()
	
	return new_order

static func get_main_wait(amount :int) -> int:
	var main_wait := 60
	
	if amount > S_MAIN_ORDER:
		main_wait = 200
	if amount > M_MAIN_ORDER:
		main_wait = 400
	if amount > L_MAIN_ORDER:
		main_wait = 600
	
	return main_wait
	
