extends XRToolsInteractableHandle

var stove_on: bool = false 

var picked_up_degrees :Vector3 = Vector3(0,0,0)
var picked_up_state :bool = false

signal toggle_stove(status :bool)

func _process(delta):
	super._process(delta)
	if(picked_up_state):
		if(!stove_on):
			if(rotation_degrees.z - picked_up_degrees.z > 0):
				stove_on = true
				toggle_stove.emit(stove_on)
		else:
			if(rotation_degrees.z - picked_up_degrees.z < -90):
				stove_on = false
				toggle_stove.emit(stove_on)
	else:
		if(!stove_on):
			if(rotation_degrees.z - picked_up_degrees.z > 90):
				stove_on = true
				toggle_stove.emit(stove_on)
		else:
			if(rotation_degrees.z - picked_up_degrees.z < 0):
				stove_on = false
				toggle_stove.emit(stove_on)

func pick_up(by) -> void:
	# Call the base-class to perform the pickup
	picked_up_degrees = rotation_degrees
	picked_up_state = stove_on
	
	super(by)

func let_go(by: Node3D, _p_linear_velocity: Vector3, _p_angular_velocity: Vector3) -> void:
	# Call the base-class to perform the drop, but with no velocity
	super(by, Vector3.ZERO, Vector3.ZERO)
	
	if(stove_on):
		rotation_degrees.z = 90
	else:
		rotation_degrees.z = 0
