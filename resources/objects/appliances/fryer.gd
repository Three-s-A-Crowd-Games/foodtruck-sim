extends Node3D

@onready var switch_top :Node3D = $"fryer/switch-top"
@onready var frying_area: FryingArea = $FryingArea

var active :bool = false

func _on_interactable_area_button_button_pressed(button):
	print("Fryeeer")
	active = !active
	frying_area.enabled = !frying_area.enabled
	if active:
		switch_top.rotation.x = 25
		pass
	else:
		switch_top.rotation.x = 0
		pass


func _on_area_3d_area_entered(area):
	print("Yeeehawww")


func _on_area_3d_body_entered(body):
	print("YeeehawwwDifferent")


func _on_area_3d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print("more yeeehaaaaawww")
