extends OpenXRHand
class_name XRTrackedHand

signal on_grib_activated
signal on_grib_deactivated

func _on_hand_pose_matcher_new_pose(previous_pose, pose):
	if pose == &"Grip" or pose == &"Fist" or pose == &"Thumb":
		on_grib_activated.emit()
	else:
		on_grib_deactivated.emit()
