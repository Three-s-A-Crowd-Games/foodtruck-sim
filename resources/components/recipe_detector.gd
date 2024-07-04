extends XRToolsSnapZone

# Require first element to be in this group and ignore
@export var first_element_ignore_group :String

@onready var orig_shape = $CollisionShape3D.shape

func check_for_recipe(recipe: Recipe) -> bool:
	if not is_instance_valid(recipe):
		return false
	
	var rev_ingredients = recipe.ingredients
	rev_ingredients.reverse()
	return _recursive_check(rev_ingredients, 0, picked_up_object)

func pick_up_object(body :Node3D):
	super.pick_up_object(body)
	$CollisionShape3D.shape = body.find_children("*","CollisionShape3D")[0].shape

func drop_object():
	super.drop_object()
	$CollisionShape3D.shape = orig_shape

func _recursive_check(ingredients: Array[Ingredient.Type], index: int, rawObject: XRToolsPickable) -> bool:
	if not is_instance_valid(rawObject):
		if ingredients.is_empty():
			# Empty slot -> empty recipe
			return true
		return false
	
	var stack_zone: XRToolsSnapZone = null
	var snap_zones = rawObject.find_children("*", "XRToolsSnapZone", false, false)
	if snap_zones.size() > 0:
		stack_zone = snap_zones[0]
	
	var object :Food = null
	var is_first_ignore = false
	if rawObject is Food:
		object = rawObject
	else:
		is_first_ignore = first_element_ignore_group != "" and index == 0 and rawObject.is_in_group(first_element_ignore_group)
		if !is_first_ignore:
			return false
	
	# Last element in stack
	# We do not have to check for sauce here as that cannot happen due to the top-bun being required
	if not stack_zone or not stack_zone.picked_up_object:
		if index == ingredients.size() - 1 and object != null:
			return ingredients[index] == object.type
		else:
			return false
	
	if is_first_ignore:
		return _recursive_check(ingredients, index, stack_zone.picked_up_object)
	# All other elements
	index += 1
	if object.type != ingredients[index-1]:
		printt("WrongItem", object.type)
		return false
	else:
		#Check if Cooked/Fried
		if object.is_in_group("cookable") and object.get_node("Cookable").status != Cookable.CookedStatus.COOKED:
			return false
		if object.is_in_group("fryable") and object.get_node("Fryable").status != Fryable.FryStatus.FRYED:
			return false
		#Check if current object is sauced (if it's food) and check if the next Item is also Sauce -> if so skip the next ingredient
		if object is BurgerPart and object.sauced != -1:
			#It is sauced. Should it be?
			if ingredients[index] == object.sauced:
				index += 1
		return _recursive_check(ingredients, index, stack_zone.picked_up_object)
