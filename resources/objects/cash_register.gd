extends Node3D

var order_papers :Array
var trays :Array

# Called when cash register is pressed
func _on_interactable_area_button_button_pressed(button: Variant) -> void:
	for order_paper :OrderPaper in order_papers:
		for tray :Tray in trays:
			if tray.check_order(order_paper.order):
				# Order is correct!
				order_paper.order.tray = tray
				OrderController.finish_order(order_paper.order)


func _on_order_detection_area_body_entered(body: Node3D) -> void:
	if body is OrderPaper:
		order_papers.append(body)
	if body is Tray:
		trays.append(body)


func _on_order_detection_area_body_exited(body: Node3D) -> void:
	if body is OrderPaper:
		order_papers.erase(body)
	if body is Tray:
		trays.erase(body)
