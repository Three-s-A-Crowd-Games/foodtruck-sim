extends XRToolsInteractableAreaButton

signal back_to_menu_requested

func _on_button_pressed(_button: Variant) -> void:
	back_to_menu_requested.emit()
