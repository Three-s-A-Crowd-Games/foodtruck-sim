class_name BurgerStackZone
extends XRToolsSnapZone

# Called when a body enters the snap zone
func _on_snap_zone_body_entered(target: Node3D) -> void:
	# Reject parent object
	if target == get_parent():
		return
	
	super._on_snap_zone_body_entered(target)

#func pick_up_object(target: Node3D) -> void:
	#super.pick_up_object(target)
	#
	#var coll_node: CollisionShape3D = picked_up_object.get_node_or_null("CollisionShape3D")
	#if not coll_node: return
	#
	#coll_node.disabled = true
	##picked_up_object.collision_mask -= 16^2
	#
	#var c = CollisionShape3D.new()
	#c.transform.basis = coll_node.transform.basis
	#c.position = coll_node.position + position
	#printt(c.position, c.global_position)
	#printt(coll_node.position, coll_node.global_position)
	#c.shape = coll_node.shape
	#c.name += str(picked_up_object.get_instance_id())
	#c.add_child(load("res://coordinate2.tscn").instantiate())
	#add_sibling(c)
	#printt("shape", c.shape)
	#printt("name", c.name)
	#printt("owner", c.owner)
	#
#
#func drop_object() -> void:
	#var coll_node: CollisionShape3D = picked_up_object.get_node_or_null("CollisionShape3D")
	#var children := owner.find_children("*"+str(picked_up_object.get_instance_id()), "CollisionShape3D", false, false)
	#coll_node.disabled = false
	#assert(children.size() == 1)
	#owner.remove_child(children[0])
	#children[0].queue_free()
	#super.drop_object()
	
