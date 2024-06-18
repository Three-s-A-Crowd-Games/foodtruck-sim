extends Node

const MAX_ORDER_NUM = 3

var cur_number :int = 0
var cur_orders :Array = []

# This is temporary! Not needed after Customer is a thing!
var orders_done :Array = []

signal created_order(le_order :Order)
signal finished_order(le_order :Order)
signal failed_order(le_order :Order)

func create_new_order() -> Order:
	if cur_orders.size() >= MAX_ORDER_NUM:
		return null
	cur_number+=1
	var new_order = Order.create_order(cur_number)
	cur_orders.append(new_order)
	created_order.emit(new_order)
	new_order.out_of_time.connect(_fail_order)
	return new_order

func finish_order(le_order :Order):
	le_order.completed()
	orders_done.append(le_order)
	finished_order.emit(le_order)
	cur_orders.erase(le_order)

func _fail_order(le_order :Order):
	cur_orders.erase(le_order)
	failed_order.emit(le_order)
