extends XRToolsInteractableAreaButton


func _on_button_pressed(button: Variant) -> void:
	var new_order = OrderController.create_new_order()
	if new_order != null:
		var new_paper = load("res://resources/objects/order_paper.tscn").instantiate()
		$Order_Paper_Spawner.add_child(new_paper)
		new_paper.set_order(new_order)
		new_order.order_paper = new_paper
