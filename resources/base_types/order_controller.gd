class_name OrderController
extends RefCounted

static var cur_number :int = 0

static func get_next_num() -> int:
	cur_number+=1
	return cur_number
