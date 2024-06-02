class_name FryingArea
extends Area3D

var fryables_inside: Array[Fryable] = []
@export var enabled: bool = false :
	set(value):
		enabled = value
		if value:
			for fryable:Fryable in fryables_inside:
				fryable.start_cooking()
		else:
			for fryable:Fryable in fryables_inside:
				fryable.stop_cooking()
			

# Does not always start cooking - hence an extra signal to check with the appliance
func _on_body_entered(body):
	if(body.is_in_group("fryable")):
		var fryable = body.get_node("Fryable")
		fryables_inside.append(fryable)
		#cooking_area_entered.emit(body)
		if enabled:
			fryable.start_cooking();

# Always stops cooking
func _on_body_exited(body):
	if(body.is_in_group("fryable")):
		var fryable = body.get_node("Fryable")
		fryables_inside.erase(fryable)
		fryable.stop_cooking();
