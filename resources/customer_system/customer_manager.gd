extends Node3D

const CUSTOMER_RESPAWN_TIME = 5
const MAX_CUSTOMER_WAITING = 3
const CUSTOMER_WAITING_DISTANCE = 0.6

@onready var available_waiting_pos := $WaitingPoss.get_children()
@onready var cust_scene :PackedScene = preload("res://resources/customer_system/customer.tscn")

var customers_inline :Array
var customers_waiting_for_food :Array
var path_follows :Array
var waiting_follows :Array
var waiting_pos_usage :Dictionary = {}
var order_dict :Dictionary = {}

var waiting_pos_stop_values = {
	"Pos1": 0.2815,
	"Pos2": 0.3364,
	"Pos3": 0.3123
}

var spawn_timer :Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = CUSTOMER_RESPAWN_TIME
	spawn_timer.timeout.connect(spawn_customer_if_possible)
	self.add_child(spawn_timer)
	spawn_timer.start()
	
	OrderController.created_order.connect(_got_order)
	OrderController.failed_order.connect(_failed_order)
	OrderController.finished_order.connect(_finished_order)
	for child in $WaitingPoss.get_children():
		waiting_pos_usage.get_or_add(child)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	advance_path_follows(delta)

func advance_path_follows(delta: float):
	delta /= 8
	for i in range(path_follows.size()):
		var cur_follow :PathFollow3D = path_follows[i]
		if(cur_follow.progress_ratio < 1):
			#Check if customer infront
			if(i != 0 and path_follows[i-1].progress - cur_follow.progress <= CUSTOMER_WAITING_DISTANCE):
				continue
			if(cur_follow.progress_ratio + delta > 1):
				OrderController.someone_waiting = true
				cur_follow.progress_ratio = 1
			else:
				cur_follow.progress_ratio += delta
	for i in range(waiting_follows.size()):
		if(!is_instance_valid(waiting_follows[i])): continue
		var cur_follow :PathFollow3D = waiting_follows[i]
		var customer :Customer = cur_follow.get_child(0)
		if(!is_instance_valid(customer)): continue
		if(cur_follow.progress_ratio < customer.waiting_pos_stop_value):
			if(cur_follow.progress_ratio + delta > customer.waiting_pos_stop_value):
				cur_follow.progress_ratio = customer.waiting_pos_stop_value + 0.0001
			else:
				cur_follow.progress_ratio += delta
		elif(cur_follow.progress_ratio < 1 and customer.can_leave):
			if(cur_follow.progress_ratio + delta > 1):
				if customer.tray != null: customer.tray.nuke()
				cur_follow.queue_free()
			else:
				cur_follow.progress_ratio += delta

func spawn_customer_if_possible():
	if customers_inline.size() < MAX_CUSTOMER_WAITING:
		var new_cust :Customer = cust_scene.instantiate()
		new_cust.randomize_appearance()
		customers_inline.append(new_cust)
		
		var path_follow := PathFollow3D.new()
		$TheLine.add_child(path_follow)
		path_follow.add_child(new_cust)
		path_follows.append(path_follow)

func get_wait_pos():
	for pot_pos in waiting_pos_usage:
		if(waiting_pos_usage.get(pot_pos) == null):
			return pot_pos

func _got_order(le_order :Order):
	var wait_pos :Path3D = get_wait_pos()
	var customer :Customer = customers_inline[0]
	customers_inline.erase(customer)
	waiting_pos_usage[wait_pos] = customer
	order_dict[le_order] = customer
	
	var cust_par = customer.get_parent()
	customer.wait_pos = wait_pos
	cust_par.remove_child(customer)
	path_follows.erase(cust_par)
	cust_par.queue_free()
	
	var path_follow := PathFollow3D.new()
	wait_pos.add_child(path_follow)
	path_follow.add_child(customer)
	waiting_follows.append(path_follow)
	customer.waiting_pos_stop_value = waiting_pos_stop_values[wait_pos.get_name()]

func _failed_order(le_order :Order):
	var customer = order_dict[le_order]
	waiting_pos_usage[customer.wait_pos] = null
	customer.angry()

func _finished_order(le_order :Order):
	var customer = order_dict[le_order]
	waiting_pos_usage[customer.wait_pos] = null
	customer.happy(le_order.tray)
