extends Node3D

var stove_on: bool = false

func _process(delta):
	var knob_model = $"stove-v2/knob"
	var knob_turner = $KnobOrigin/KnobTurner
	
	if(!stove_on):
		if(knob_turner.global_rotation_degrees.z>90):
			toggle_stove()
	if(stove_on):
		if(knob_turner.global_rotation_degrees.z<0):
			toggle_stove()

func toggle_stove():
	var knob_model = $"stove-v2/knob"
	if(stove_on):
		knob_model.rotation_degrees.z = 0
	else:
		knob_model.rotation_degrees.z = 90
	stove_on = !stove_on
	toggle_bodies_in_area()

func toggle_bodies_in_area():
	for body in $CookingArea.bodies_inside:
		if(stove_on):
			body.get_node("Cookable").start_cooking()
		else:
			body.get_node("Cookable").stop_cooking()

func _on_cooking_area_cooking_area_entered(body):
	if(stove_on):
		body.get_node("Cookable").start_cooking()
