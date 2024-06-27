class_name BurgerPart
extends Food

# New Constraint:	The mechanic for flipping a Burgerpart assumes that the model/mesh
#					is placed directly on top of the xz-plane.

enum FlipState {FLIPPED=-1, UNFLIPPED=1}

var flipped_state: FlipState = FlipState.UNFLIPPED
var stack_zone_distance: float
var height: float
var burger_part_seperation_distance = 0.01
var is_reversing := false
var sauced :Ingredient.Type = -1
var original_center_of_mass := Vector3.ZERO
var is_stack_root: bool:
	get():
		return not get_picked_up_by() is BurgerStackZone

@onready var stack_zone: BurgerStackZone = $BurgerStackZone
@onready var original_mass := mass

func _ready():
	super._ready()
# INFO: The properties set in this method won't be correct for slices.
# Therefore they will be overwritten afterwards by the sliceable component.
	stack_zone.has_picked_up.connect(_on_burger_stack_zone_has_picked_up)
	stack_zone.has_dropped.connect(_on_burger_stack_zone_has_dropped)
	
	var mesh_nodes = find_children("*", "MeshInstance3D", true, false)
	#assert(mesh_nodes.size() == 1, "This Burger Part has either 0 or more than one mesh nodes, which can't be handled so far.")
	var mesh_node: MeshInstance3D = mesh_nodes[0]
	var aabb = mesh_node.mesh.get_aabb()
	height = aabb.size.y + aabb.position.y
	if mesh_node.get_parent() == self:
		stack_zone_distance = height + mesh_node.position.y
	else:
		stack_zone_distance = height + mesh_node.get_parent().position.y
	
	original_center_of_mass.y = stack_zone_distance - height/2
	#stack_zone_distance += aabb.position.y
	stack_zone_distance += burger_part_seperation_distance
	stack_zone.position.y = stack_zone_distance
	
	center_of_mass = original_center_of_mass
	

func _process(_delta):
	if is_stack_root and adjust_flip() and (not is_picked_up() or get_picked_up_by() is XRToolsFunctionPickup):
		_reverse_stack(_grab_driver.primary.pickup if _grab_driver else null)
		get_stack_root()._recalculate_mass()
	

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
	var part_below: BurgerPart = null
	if not is_stack_root:
		part_below = get_picked_up_by().get_parent()
	
	if stack_zone.has_snapped_object():
		assert(stack_zone.picked_up_object is BurgerPart, "BurgerStackZone picked up a non Burgerpart and now tries to flip the stack. Not good :(")
		stack_zone.picked_up_object._reverse_stack(hand_pickup)
	elif hand_pickup:
		hand_pickup._pick_up_object(self)
	
	stack_zone.transform = get_current_stack_zone_trans(part_below)
	
	if part_below:
		stack_zone.pick_up_object(part_below)
	else:
		var obj := stack_zone.picked_up_object as BurgerPart
		if obj and obj.dropped.is_connected(stack_zone._on_target_dropped):
			obj.dropped.disconnect(stack_zone._on_target_dropped)
		stack_zone.drop_object()
		return
	
	is_reversing = false
	return
	

func _on_burger_stack_zone_has_picked_up(what: BurgerPart):
	prints(what.name, "picked up by", name)
	if not is_reversing:
		stack_zone.transform = get_current_stack_zone_trans(what)
		var root = get_stack_root()
		root.mass += what.mass
		root.center_of_mass.y += what.center_of_mass.y + burger_part_seperation_distance/2
	

func _on_burger_stack_zone_has_dropped(what: BurgerPart):
	prints(what.name, "dropped by", name)
	if not is_reversing:
		stack_zone.transform = get_current_stack_zone_trans(null)
		get_stack_root()._recalculate_mass(what)
		what._recalculate_mass()
	

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
	

func get_stack_root() -> BurgerPart:
	if is_stack_root:
		return self
	else:
		return get_picked_up_by().get_parent().get_stack_root()
	

# WARNING: This is not 100% phisycally correct,
# since the center of mass is allways in the middle no matter how heavy a part is.
# But I guess it should be good enaugh
func _recalculate_mass(until: BurgerPart = null) -> void:
	var new_mass := 0.0
	var new_center_of_mass := Vector3.ZERO
	var part := self
	
	while part != until:
		new_mass += part.original_mass
		new_center_of_mass.y += part.original_center_of_mass.y + burger_part_seperation_distance/2
		part = part.stack_zone.picked_up_object
	
	mass = new_mass
	center_of_mass = new_center_of_mass
