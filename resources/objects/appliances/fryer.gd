extends Node3D

@onready var switch_top :Node3D = $"fryer/switch-top"
@onready var frying_area: FryingArea = $FryingArea

var active :bool = false

func _on_interactable_area_button_button_pressed(button):
	active = !active
	frying_area.enabled = !frying_area.enabled
	if active:
		switch_top.rotation_degrees = Vector3(25,0,0)
		pass
	else:
		switch_top.rotation_degrees = Vector3(0,0,0)
		pass
