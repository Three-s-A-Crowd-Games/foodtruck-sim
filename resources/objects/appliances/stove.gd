extends Node3D

@onready var knob_model: MeshInstance3D  = $"stove-v2/knob"
@onready var cooking_area: CookingArea = $CookingArea

func _on_toggle_stove(stove_on :bool):
	if(stove_on):
		knob_model.rotation_degrees.z = 90
	else:
		knob_model.rotation_degrees.z = 0
	cooking_area.enabled = !cooking_area.enabled
