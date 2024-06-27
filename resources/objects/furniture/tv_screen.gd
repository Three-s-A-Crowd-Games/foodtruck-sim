extends Node3D

@onready var bar_scene := preload("res://resources/objects/furniture/order_progress_display.tscn")

var order_bars :Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OrderController.created_order.connect(_add_order)
	OrderController.finished_order.connect(_remove_order)
	OrderController.failed_order.connect(_remove_order)

func _add_order(le_order :Order):
	var new_order_bar :OrderProgressDisplay = bar_scene.instantiate()
	$SubViewport/MainContainer.add_child(new_order_bar)
	new_order_bar.setup(le_order)
	order_bars.get_or_add(le_order, new_order_bar)

func _remove_order(le_order :Order):
	var order_bar :OrderProgressDisplay = order_bars.get(le_order)
	order_bar.queue_free()
	order_bars.erase(le_order)
