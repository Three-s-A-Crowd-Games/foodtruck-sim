class_name BurgerPart
extends Food

#TODO: adjust the recipe detection
#TODO: adjust mass when stacked and shift center of mass

enum FlipState {UNINITIALIZED, FLIPPED, UNFLIPPED}

var flipped_state: FlipState = FlipState.UNINITIALIZED :
	set(value):
		flipped_state = value
var is_root = true
var flipped_transform: Transform3D
var unflipped_transform: Transform3D
var outer_stack_zone: BurgerStackZone
var burger_part_stack: Array[BurgerPart] = [self]
var stack_zone_stack: Array[BurgerStackZone]

func _ready():
	outer_stack_zone = get_node_or_null("BurgerStackZone")
	if not outer_stack_zone: return
	unflipped_transform = outer_stack_zone.transform
	flipped_transform = outer_stack_zone.transform * -1
	stack_zone_stack.append(outer_stack_zone)
	if outer_stack_zone:
		outer_stack_zone.has_picked_up.connect(_on_burger_stack_zone_has_picked_up)
		outer_stack_zone.has_dropped.connect(_on_burger_stack_zone_has_dropped)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#if not is_root: 
		#printt("return 1", name)
		#return
	#if not outer_stack_zone:
		#printt("return 2", name)
		#return
	#if outer_stack_zone.picked_up_object:
		#printt("return 3", name)
		#return
	#if is_picked_up() and _grab_driver.primary.by is BurgerStackZone: 
		#printt("return 4", name)
		#return
	if flipped_state == FlipState.UNINITIALIZED and global_transform.basis.y.angle_to(Vector3.UP) > PI/2:
		flipped_state = FlipState.UNFLIPPED
		return
	if flipped_state == FlipState.UNINITIALIZED and global_transform.basis.y.angle_to(Vector3.UP) < PI/2:
		flipped_state = FlipState.FLIPPED
		return
	if flipped_state == FlipState.FLIPPED and global_transform.basis.y.angle_to(Vector3.UP) > 11*PI/20:
		#print("***************")
		#printt("unflipped", unflipped_transform)
		#printt("flipped", flipped_transform)
		#printt("current", outer_stack_zone.transform)
		#printt("check", outer_stack_zone.transform * -1 == flipped_transform)
		#outer_stack_zone.transform = flipped_transform
		#burger_part_stack.all(func(x): x.flipped = not x.flipped)
		if is_root: _reverse_stack()
		flipped_state = FlipState.UNFLIPPED
		print()
		print("------------------flip------------------")
		print()
	elif flipped_state == FlipState.UNFLIPPED and global_transform.basis.y.angle_to(Vector3.UP) < 9*PI/20:
		#outer_stack_zone.transform = unflipped_transform
		#burger_part_stack.all(func(x): x.flipped = not x.flipped)
		if is_root: _reverse_stack()
		flipped_state = FlipState.FLIPPED
		print()
		print("------------------unflip------------------")
		print()

func _reverse_stack() -> void:
	if stack_zone_stack.size() == 1:
		outer_stack_zone.transform *= -1
		return
		
	#TODO: Make it work with more than once
	#TODO: Make it work with flipped pieces
	var new_root: BurgerPart = burger_part_stack.back()
	var second_last_stack_zone: BurgerStackZone = stack_zone_stack[-2]
	var new_outer_stack_zone_pos: Vector3 = stack_zone_stack[0].position * Vector3(0,-1,0)
	_move_zones(stack_zone_stack, self, new_root)
	var last_2_zones: Array[BurgerStackZone] = stack_zone_stack.slice(-2)
	var zone_distance: float = last_2_zones[1].position.y - last_2_zones[0].position.y
	for zone in last_2_zones: zone.position.y -= stack_zone_stack.size() * zone_distance
	#var new_pos = new_root.to_local(to_global(new_outer_stack_zone_pos))
	#stack_zone_stack[0].global_position = to_global(new_outer_stack_zone_pos)
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
	print()
	
	# drop the last part in the stack. This also removes the last 2 zones from the stack. 
	#var new_root: BurgerPart = burger_part_stack.back()
	#var second_last_stack_zone: BurgerStackZone = stack_zone_stack[-2]
	#var first_stack_zone_pos: Vector3 = stack_zone_stack[0].position
	#second_last_stack_zone.drop_object()
	#if _grab_driver: _grab_driver.primary.pickup._pick_up_object(new_root)
	#stack_zone_stack.reverse()
	#burger_part_stack.reverse()
	#new_root.stack_zone_stack = stack_zone_stack.slice(1)
	#new_root.burger_part_stack += burger_part_stack
	#_move_zones(stack_zone_stack, self, new_root)
	#stack_zone_stack.clear()
	#burger_part_stack.clear()
	#new_root.stack_zone_stack.append(second_last_stack_zone)
	#outer_stack_zone = null
	#second_last_stack_zone.pick_up_object(self)
	#new_root.stack_zone_stack.append(new_root.outer_stack_zone)
	#new_root.outer_stack_zone.global_position = to_global(first_stack_zone_pos * -1)
	print("done")


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
	what = what as BurgerPart
	#if outer_stack_zone.transform == flipped_transform:
		#print("Now you entered flipped. As user of this feature, respectfully: GO FUCK YOURSELF")
		#assert(burger_part_stack.size() == stack_zone_stack.size(), "burger_part_stack and stack_zone_stack got unbalanced")
		#var new_root: BurgerPart = burger_part_stack.back()
		#new_root.flipped_transform = unflipped_transform
		#
		#for i in range(burger_part_stack.size()):
			##burger_part.transform.basis.y *= -1	dont do this!
			#burger_part_stack[i].unflipped_transform = burger_part_stack[i].flipped_transform
			#burger_part_stack[i].flipped_transform *= -1
			##burger_part_stack[i].flipped = not burger_part_stack[i].flipped #idk if this is good
		#
		#stack_zone_stack[-2].drop_object()
		#
		#for i in stack_zone_stack.size():
			#var prev_pos = stack_zone_stack[i].global_position
			#remove_child(stack_zone_stack[i])
			#new_root.add_child(stack_zone_stack[i], true)
			#stack_zone_stack[i].global_position = prev_pos
			#stack_zone_stack[i].pick_up_object(burger_part_stack[i])
			#stack_zone_stack[i].has_picked_up.disconnect(_on_burger_stack_zone_has_picked_up)
			#stack_zone_stack[i].has_picked_up.connect(new_root._on_burger_stack_zone_has_picked_up)
			#stack_zone_stack[i].has_dropped.disconnect(_on_burger_stack_zone_has_dropped)
			#stack_zone_stack[i].has_dropped.connect(new_root._on_burger_stack_zone_has_dropped)
		#
		#
		#new_root.outer_stack_zone = outer_stack_zone
		#outer_stack_zone = null
		#is_root = false
		#new_root.is_root = true
		#burger_part_stack.reverse()
		#new_root.burger_part_stack = burger_part_stack
		#burger_part_stack.clear()
		#stack_zone_stack.reverse()
		#new_root.stack_zone_stack = stack_zone_stack
		#stack_zone_stack.clear()
		#
		#new_root._on_burger_stack_zone_has_picked_up(what)
		#return
	assert(what.burger_part_stack.size() == what.stack_zone_stack.size(), "burger_part_stack and stack_zone_stack got unbalanced")
	if what.outer_stack_zone: outer_stack_zone = what.outer_stack_zone
	_move_zones(what.stack_zone_stack, what, self)
	#for stack_zone: BurgerStackZone in what.stack_zone_stack:
		#if not stack_zone:
			#outer_stack_zone = null
			#assert(false, "this is a test if this case even occurs. If you run into it pleas contact Henry")
			#continue
		#var prev_pos := stack_zone.global_position
		#what.remove_child(stack_zone)
		#add_child(stack_zone, true)
		#stack_zone.global_position = prev_pos
		#stack_zone.has_picked_up.disconnect(what._on_burger_stack_zone_has_picked_up)
		#stack_zone.has_picked_up.connect(_on_burger_stack_zone_has_picked_up)
		#stack_zone.has_dropped.disconnect(what._on_burger_stack_zone_has_dropped)
		#stack_zone.has_dropped.connect(_on_burger_stack_zone_has_dropped)

	what.is_root = false
	burger_part_stack += what.burger_part_stack
	what.burger_part_stack.clear()
	stack_zone_stack += what.stack_zone_stack
	what.stack_zone_stack.clear()
	#unflipped_transform = what.unflipped_transform
	#unflipped_transform.origin = to_local(stack_zone_stack.back().global_position)
	what.outer_stack_zone = null
	printt("is_root 1", is_root, name)


func _on_burger_stack_zone_has_dropped(what):
	assert(what is BurgerPart)
	assert(is_root)
	what = what as BurgerPart
	what.is_root = true
	assert(what.burger_part_stack.size() == what.stack_zone_stack.size(), "burger_part_stack and stack_zone_stack got unbalanced")
	var index = burger_part_stack.find(what)
	if index == 0: return # 0 index means this object is dropping itself. This should only happen as consequence of _reverse_stack()EEEE
	#assert(index > 0, "removed item was somehow not in the stack or removed itself")
	what.burger_part_stack += burger_part_stack.slice(index)
	burger_part_stack.resize(index)
	what.stack_zone_stack += stack_zone_stack.slice(index)
	stack_zone_stack.resize(index)
	what.outer_stack_zone = outer_stack_zone
	outer_stack_zone = stack_zone_stack.back()
	
	_move_zones(what.stack_zone_stack, self, what)
	#for stack_zone: BurgerStackZone in what.stack_zone_stack:
		#if not stack_zone:
			#outer_stack_zone = null
			#continue
		#var prev_pos := stack_zone.global_position
		#remove_child(stack_zone)
		#what.add_child(stack_zone, true)
		#stack_zone.global_position = prev_pos
		#stack_zone.has_picked_up.disconnect(_on_burger_stack_zone_has_picked_up)
		#stack_zone.has_picked_up.connect(what._on_burger_stack_zone_has_picked_up)
		#stack_zone.has_dropped.disconnect(_on_burger_stack_zone_has_dropped)
		#stack_zone.has_dropped.connect(what._on_burger_stack_zone_has_dropped)
	
	#what.unflipped_transform = unflipped_transform
	#what.unflipped_transform.origin = what.outer_stack_zone.position
	#unflipped_transform = burger_part_stack.back().unflipped_transform
	#unflipped_transform.origin = to_local(stack_zone_stack.back().global_position)
		#print("+++++++++++++++++++++")
		#printt("prev pos", prev_pos)
		#printt("self", unflipped_transform)
		#printt("what", what.unflipped_transform)
		#print()
