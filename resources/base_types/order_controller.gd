class_name OrderController
extends RefCounted

static var cur_number :int = 0
static var cur_orders :Array = []

static func get_new_order() -> Order:
	cur_number+=1
	var new_order = Order.create_order(cur_number)
	cur_orders.append(new_order)
	return new_order
