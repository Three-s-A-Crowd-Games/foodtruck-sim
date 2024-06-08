@tool
class_name Food
extends XRToolsPickable

@export var type: Ingredient.Type

func pick_up(by: Node3D) -> void:
	freeze = false
	super.pick_up(by)
