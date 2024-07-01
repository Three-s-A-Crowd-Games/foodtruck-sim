extends Node3D

const CASH_DRAWER_OPEN_DISTANCE := 0.265
const OPEN_SOUND_DURATION := 1.1
var trays :Array
var is_open := false
var tween: Tween
@onready var cash_drawer_nodes: Array[Node3D] = [$cash_register/Cube_001, $cash_register/Cylinder]

func _on_order_check_timer_timeout() -> void:
	#check for completed orders
	for order :Order in OrderController.cur_orders:
		for tray :Tray in trays:
			if tray.check_order(order):
				# Order is correct!
				order.tray = tray
				OrderController.finish_order(order)
				#open cash drawer
				if tween.is_running():
					await tween.finished
				if not tween or not tween.is_valid():
					tween = create_tween()
				tween.set_parallel()
				for node: Node3D in cash_drawer_nodes:
					tween.tween_property(node, "position:z", node.position.z + CASH_DRAWER_OPEN_DISTANCE, OPEN_SOUND_DURATION).set_ease().set_trans()

# Called when cash register is pressed
func _on_interactable_area_button_button_pressed(button: Variant) -> void:
	pass


func _on_order_detection_area_body_entered(body: Node3D) -> void:
	if body is Tray:
		trays.append(body)


func _on_order_detection_area_body_exited(body: Node3D) -> void:
	if body is Tray:
		trays.erase(body)
