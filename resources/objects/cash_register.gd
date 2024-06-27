extends Node3D

var trays :Array

# Called when cash register is pressed
func _on_interactable_area_button_button_pressed(button: Variant) -> void:
	for order :Order in OrderController.cur_orders:
		for tray :Tray in trays:
			if tray.check_order(order):
				# Order is correct!
				order.tray = tray
				OrderController.finish_order(order)


func _on_order_detection_area_body_entered(body: Node3D) -> void:
	if body is Tray:
		trays.append(body)


func _on_order_detection_area_body_exited(body: Node3D) -> void:
	if body is Tray:
		trays.erase(body)
