extends XRToolsCollisionHand

var shape_node :CollisionShape3D

func _on_function_pickup_has_picked_up(what):
	# This doesn't work properly
	if (what is not XRToolsInteractableHandle and what is not OrderPaper):
		var orig_node :Node3D = what.get_node("CollisionShape3D")
		shape_node = orig_node.duplicate()
		
		add_child(shape_node)
		shape_node.global_position = orig_node.global_position
		shape_node.global_rotation = orig_node.global_rotation
		shape_node.scale = orig_node.scale
		collision_mask = 1


func _on_function_pickup_has_dropped():
	if shape_node: remove_child(shape_node)
	shape_node = null
	collision_mask = 0
