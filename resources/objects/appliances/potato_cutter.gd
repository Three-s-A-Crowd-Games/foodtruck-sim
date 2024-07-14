extends Node3D

signal sliced

var machine_slicable_inside = []


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Food and body.get_node("MachineSlicable") != null:
		machine_slicable_inside.append(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if machine_slicable_inside.has(body):
		machine_slicable_inside.erase(body)


func _on_interactable_slider_slider_limit_min_reached() -> void:
	if machine_slicable_inside.is_empty(): return
	for machine_slicable in machine_slicable_inside:
		if machine_slicable.get_node("MachineSlicable").slice():
			sliced.emit()
	
