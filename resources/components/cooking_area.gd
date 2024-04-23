extends Area3D

var bodies_inside = []
signal cooking_area_entered(body)

# Does not always start cooking - hence an extra signal to check with the appliance
func _on_body_entered(body):
	print("body entered")
	if(body.is_in_group("cookable")):
		bodies_inside.append(body)
		cooking_area_entered.emit(body)

# Always stops cooking
func _on_body_exited(body):
	print("body exited")
	if(body.is_in_group("cookable")):
		bodies_inside.erase(body)
		body.get_node("Cookable").stop_cooking();
