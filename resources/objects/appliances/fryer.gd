extends Node3D

@onready var switch_top :Node3D = $"fryer/switch-top"
@onready var frying_area: FryingArea = $FryingArea

var active :bool = false

func _on_interactable_area_button_button_pressed(button):
	active = !active
	frying_area.enabled = !frying_area.enabled
	if active:
		switch_top.rotation_degrees.x = 25
		$GPUParticles3D.emitting = true
		$GPUParticles3D2.emitting = true
		pass
	else:
		switch_top.rotation_degrees.x = 0
		$GPUParticles3D.emitting = false
		$GPUParticles3D2.emitting = false
		pass
