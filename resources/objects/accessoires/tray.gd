class_name Tray
extends XRToolsPickable

@onready var main_zone := $MainZone
@onready var side_zone := $SideZone
@onready var drink_zone := $DrinkZone

func check_order(order :Order) -> bool:
	var main_check = main_zone.check_for_recipe(order.main_recipe)
	var side_check = side_zone.check_for_recipe(order.side_recipe)
	var drink_check = drink_zone.check_for_recipe(order.drink_recipe)
	if (main_check and side_check and drink_check):
		return true
	# Wrong order
	return false

# This is ugly - but it works.
func nuke():
	var to_be_nuked :Array[Node3D] = []
	var cur_snap :XRToolsSnapZone
	for root_zone in [main_zone, side_zone, drink_zone]:
		cur_snap = root_zone
		while(cur_snap != null):
			if(is_instance_valid(cur_snap.picked_up_object)):
				to_be_nuked.append(cur_snap.picked_up_object)
				var snap_zones = cur_snap.picked_up_object.find_children("*", "XRToolsSnapZone", false, false)
				if snap_zones.size() > 0:
					cur_snap = snap_zones[0]
				else:
					cur_snap = null
			else:
				cur_snap = null
		root_zone.drop_object()
		
	for thing :XRToolsPickable in to_be_nuked:
		thing.queue_free()
	# Delete tray
	self.queue_free()
