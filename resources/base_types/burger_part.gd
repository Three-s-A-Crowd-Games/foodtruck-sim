@tool
class_name BurgerPart
extends Food

# Constraint:	The distance between a burgerpart and the corresponding stack zone
# 				needs to be the same for all burgerparts in a stack

#TODO: adjust the recipe detection
#TODO: adjust mass when stacked and shift center of mass

enum FlipState {UNINITIALIZED, FLIPPED, UNFLIPPED}

var flipped_state: FlipState = FlipState.UNINITIALIZED :
	set(value):
		flipped_state = value
var is_root = true
var outer_stack_zone: BurgerStackZone
var burger_part_stack: Array[BurgerPart] = [self]
var stack_zone_stack: Array[BurgerStackZone]

@export var stack_zone_distance: float = 0.05 :
	set(value):
		stack_zone_distance = value
		if is_inside_tree() and $BurgerStackZone:
			$BurgerStackZone.position.y = value

func _ready():
	outer_stack_zone = get_node_or_null("BurgerStackZone")
	if not outer_stack_zone: return
	stack_zone_stack.append(outer_stack_zone)
	if outer_stack_zone:
		outer_stack_zone.enabled = true
		outer_stack_zone.has_picked_up.connect(_on_burger_stack_zone_has_picked_up)
		outer_stack_zone.has_dropped.connect(_on_burger_stack_zone_has_dropped)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if flipped_state == FlipState.UNINITIALIZED and global_transform.basis.y.angle_to(Vector3.UP) > PI/2:
		flipped_state = FlipState.UNFLIPPED
		return
	if flipped_state == FlipState.UNINITIALIZED and global_transform.basis.y.angle_to(Vector3.UP) < PI/2:
		flipped_state = FlipState.FLIPPED
		return
	if flipped_state == FlipState.FLIPPED and global_transform.basis.y.angle_to(Vector3.UP) > 11*PI/20:
		if is_root: _reverse_stack()
		flipped_state = FlipState.UNFLIPPED
	elif flipped_state == FlipState.UNFLIPPED and global_transform.basis.y.angle_to(Vector3.UP) < 9*PI/20:
		if is_root: _reverse_stack()
		flipped_state = FlipState.FLIPPED

func _reverse_stack() -> void:
	if stack_zone_stack.size() == 1:
		outer_stack_zone.transform *= -1
		return
		
	var new_root: BurgerPart = burger_part_stack.back()
	_move_zones(stack_zone_stack, self, new_root)
	var last_2_zones: Array[BurgerStackZone] = stack_zone_stack.slice(-2)
	var zone_distance: float = last_2_zones[1].position.y - last_2_zones[0].position.y
	for zone in last_2_zones: zone.position.y -= stack_zone_stack.size() * zone_distance
	var first_zones: Array[BurgerStackZone] = stack_zone_stack.slice(0, -2)
	first_zones.reverse()
	last_2_zones.reverse()
	burger_part_stack.reverse()
	new_root.stack_zone_stack = first_zones + last_2_zones
	new_root.burger_part_stack += burger_part_stack
	stack_zone_stack.clear()
	burger_part_stack.clear()
	outer_stack_zone = null
	new_root.outer_stack_zone = new_root.stack_zone_stack.back()
	if _grab_driver: _grab_driver.primary.pickup._pick_up_object(new_root)
	new_root.flipped_state = FlipState.UNINITIALIZED
	new_root.is_root = true
	last_2_zones[1].drop_object()
	last_2_zones[0].pick_up_object(self)
	

func _move_zones(zones: Array[BurgerStackZone], from: BurgerPart, to: BurgerPart) -> void:
	var prev_pos: Vector3
	for zone: BurgerStackZone in zones:
		prev_pos = zone.global_position
		from.remove_child(zone)
		to.add_child(zone, true)
		zone.global_position = prev_pos
		zone.has_picked_up.disconnect(from._on_burger_stack_zone_has_picked_up)
		zone.has_picked_up.connect(to._on_burger_stack_zone_has_picked_up)
		zone.has_dropped.disconnect(from._on_burger_stack_zone_has_dropped)
		zone.has_dropped.connect(to._on_burger_stack_zone_has_dropped)


#TODO: test this with a burger part that has no stack zone i.e. bun top
func _on_burger_stack_zone_has_picked_up(what):
	assert(what is BurgerPart)
	assert(is_root)
	assert(what.is_root)
	assert(what.burger_part_stack.size() == what.stack_zone_stack.size(), "burger_part_stack and stack_zone_stack got unbalanced")
	what.is_root = false
	if what.outer_stack_zone: outer_stack_zone = what.outer_stack_zone
	_move_zones(what.stack_zone_stack, what, self)
	burger_part_stack += what.burger_part_stack
	what.burger_part_stack.clear()
	stack_zone_stack += what.stack_zone_stack
	what.stack_zone_stack.clear()
	what.outer_stack_zone = null


func _on_burger_stack_zone_has_dropped(what):
	assert(what is BurgerPart)
	assert(is_root)
	assert(what.burger_part_stack.size() == what.stack_zone_stack.size(), "burger_part_stack and stack_zone_stack got unbalanced")
	what.is_root = true
	var index = burger_part_stack.find(what)
	if index == 0: return # 0 index means this object is dropping itself. This should only happen as consequence of _reverse_stack()
	assert(index > 0, "removed item was somehow not in the stack")
	what.burger_part_stack += burger_part_stack.slice(index)
	burger_part_stack.resize(index)
	what.stack_zone_stack += stack_zone_stack.slice(index)
	stack_zone_stack.resize(index)
	what.outer_stack_zone = outer_stack_zone
	outer_stack_zone = stack_zone_stack.back()
	_move_zones(what.stack_zone_stack, self, what)
