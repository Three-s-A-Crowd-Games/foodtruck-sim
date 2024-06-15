class_name BurgerPart
extends Food

# New Constraint:	The mechanic for flipping a Burgerpart assumes that the model/mesh
#					is placed directly on top of the xz-plane.

enum FlipState {UNINITIALIZED=0, FLIPPED=-1, UNFLIPPED=1}

var flipped_state: FlipState = FlipState.UNINITIALIZED
var stack_zone_distance: float
var height: float
var burger_part_seperation_distance = 0.02 # TODO: find the smallest possible value
var is_reversing := false

@onready var stack_zone: BurgerStackZone = $BurgerStackZone
@onready var original_mass := mass

func _ready():
	stack_zone.has_picked_up.connect(_on_burger_stack_zone_has_picked_up)
	stack_zone.has_dropped.connect(_on_burger_stack_zone_has_dropped)
	
	var mesh_nodes = find_children("*", "MeshInstance3D", true, false)
	assert(mesh_nodes.size() == 1, "This Burger Part has either 0 or more than one mesh nodes, which can't be handled so far.")
	var mesh_node: MeshInstance3D = mesh_nodes[0]
	height = mesh_node.mesh.get_aabb().size.y
	if mesh_node.get_parent() == self:
		stack_zone_distance = height + mesh_node.position.y
	else:
		stack_zone_distance = height + mesh_node.get_parent().position.y
	stack_zone_distance += burger_part_seperation_distance
	stack_zone.position.y = stack_zone_distance
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if flipped_state == FlipState.UNINITIALIZED and global_transform.basis.y.angle_to(Vector3.UP) > PI/2:
		flipped_state = FlipState.FLIPPED
		return
	if flipped_state == FlipState.UNINITIALIZED and global_transform.basis.y.angle_to(Vector3.UP) < PI/2:
		flipped_state = FlipState.UNFLIPPED
		return
	
	if adjust_flip() and (not _grab_driver or _grab_driver.primary.by is XRToolsFunctionPickup):
		_reverse_stack(_grab_driver.primary.pickup if _grab_driver else null)
	

## checks if the burger part is flipped.
## Returns true if the current orientation doesn't match the current flipped_state. False otherwise.
func adjust_flip() -> bool:
	if flipped_state == FlipState.UNFLIPPED and global_transform.basis.y.angle_to(Vector3.UP) > 11*PI/20:
		return true
	elif flipped_state == FlipState.FLIPPED and global_transform.basis.y.angle_to(Vector3.UP) < 9*PI/20:
		return true
	return false
	

func _reverse_stack(hand_pickup: XRToolsFunctionPickup):
	flipped_state *= -1
	is_reversing = true
	var picked: BurgerPart = null
	if _grab_driver and _grab_driver.primary.by is not XRToolsFunctionPickup:
		picked = _grab_driver.primary.by.get_parent()
	
	if stack_zone.has_snapped_object():
		assert(stack_zone.picked_up_object is BurgerPart, "BurgerStackZone picked up a non Burgerpart and now tries to flip the stack.")
		stack_zone.picked_up_object._reverse_stack(hand_pickup)
	elif hand_pickup:
		hand_pickup._pick_up_object(self)
	
	stack_zone.transform = get_current_stack_zone_trans(picked)
	
	if picked:
		stack_zone.pick_up_object(picked)
	else:
		stack_zone.drop_object()
	
	is_reversing = false
	return
	

func _on_burger_stack_zone_has_picked_up(what: BurgerPart):
	prints(what.name, "picked up by", name)
	if not is_reversing: stack_zone.transform = get_current_stack_zone_trans(what)
	

func _on_burger_stack_zone_has_dropped(what: BurgerPart):
	prints(what.name, "dropped by", name)
	if not is_reversing: stack_zone.transform = get_current_stack_zone_trans(null)
	

func get_current_stack_zone_trans(picked_up_object: BurgerPart) -> Transform3D:
	var new_height := 0.0
	var new_orientation := Basis.IDENTITY
	if flipped_state != FlipState.FLIPPED:
		new_height = stack_zone_distance
	else:
		new_height = -1 * stack_zone_distance + height
		new_orientation = new_orientation.rotated(Vector3.RIGHT, PI)
	
	if picked_up_object and picked_up_object.flipped_state == FlipState.FLIPPED:
		new_height += signf(new_height) * picked_up_object.height
		new_orientation = new_orientation.rotated(Vector3.RIGHT, PI)
	
	return Transform3D(new_orientation, Vector3(0,new_height,0))
	

# TODO: hook this up with and adjust it to the new system. But first check if it is even neccessary.
#func recalculate_mass():
	#mass = original_mass
	#for i in range(1,burger_part_stack.size()):
		#burger_part_stack[i].mass = burger_part_stack[i].original_mass
		#mass += burger_part_stack[i].mass
		#burger_part_stack[i].center_of_mass = Vector3.ZERO
	#
	#if burger_part_stack[-1] != self:
		#center_of_mass = Vector3(0, burger_part_stack[-1].position.y / 2, 0)
	#else:
		#center_of_mass = Vector3.ZERO
	#
