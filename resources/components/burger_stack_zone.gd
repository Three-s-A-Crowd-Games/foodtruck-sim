class_name BurgerStackZone
extends XRToolsSnapZone

# Called when a body enters the snap zone
func _on_snap_zone_body_entered(target: Node3D) -> void:
	# Reject parent object
	if target == get_parent():
		return
	
	super._on_snap_zone_body_entered(target)
