extends Node3D

var stove_on: bool = false 

@onready var knob_model: MeshInstance3D  = $"stove-v2/knob"
@onready var knob_turner: RigidBody3D = $KnobOrigin/KnobTurner
@onready var cooking_area: CookingArea = $CookingArea

func _process(delta):
	if(!stove_on):
		if(knob_turner.rotation_degrees.z>90):
			toggle_stove()
	if(stove_on):
		if(knob_turner.rotation_degrees.z<0):
			toggle_stove()

func toggle_stove():
	#var knob_model = $"stove-v2/knob"
	if(stove_on):
		knob_model.rotation_degrees.z = 0
	else:
		knob_model.rotation_degrees.z = 90
	stove_on = !stove_on
	cooking_area.enabled = !cooking_area.enabled
	
