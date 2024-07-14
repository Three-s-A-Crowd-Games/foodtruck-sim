extends OpenXRHand
class_name XRTrackedHand

signal on_grib_activated
signal on_grib_deactivated
signal on_pinch
signal on_pinch_release

@export var controller :XRController3D

var grabbed :bool = false
var pinched :bool = false

func _on_hand_pose_matcher_new_pose(previous_pose, pose):
	var grab_pose = pose == &"Grip" or pose == &"Fist" or pose == &"Thumb" or pose == &"OK"
	if grab_pose and !grabbed:
		grabbed = true
		on_grib_activated.emit()
	elif grabbed and !grab_pose:
		grabbed = false
		on_grib_deactivated.emit()
	if pose == &"OK" and !pinched:
		pinched = true
		on_pinch.emit("trigger_click", controller)
	elif pose != &"OK" and pinched:
		pinched = false
		on_pinch_release.emit("trigger_click", controller)
