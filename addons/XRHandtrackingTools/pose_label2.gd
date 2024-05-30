extends Label3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_hand_pose_matcher_new_pose(previous_pose, pose):
	if pose == &"Grip" or pose == &"Fist" or pose == &"Thumb":
		text = "true"
	else:
		text = "false"
