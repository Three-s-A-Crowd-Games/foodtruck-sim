class_name Food
extends XRToolsPickable

var initial_position: Vector3
var has_left := false


func pick_up(by: Node3D) -> void:
	initial_position = global_position
	super.pick_up(by)
