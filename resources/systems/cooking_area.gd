class_name CookingArea
extends Area3D

var cookables_inside: Array[Cookable] = []
var enabled: bool = false :
	set(value):
		enabled = value
		if value:
			for cookable:Cookable in cookables_inside:
				cookable.start_cooking()
		else:
			for cookable:Cookable in cookables_inside:
				cookable.stop_cooking()
			

# Does not always start cooking - hence an extra signal to check with the appliance
func _on_body_entered(body):
	print("body entered")
	if(body.is_in_group("cookable")):
		var cookable = body.get_node("Cookable")
		cookables_inside.append(cookable)
		#cooking_area_entered.emit(body)
		if enabled:
			cookable.start_cooking();

# Always stops cooking
func _on_body_exited(body):
	print("body exited")
	if(body.is_in_group("cookable")):
		var cookable = body.get_node("Cookable")
		cookables_inside.erase(cookable)
		cookable.stop_cooking();
