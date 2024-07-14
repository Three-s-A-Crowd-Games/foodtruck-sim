@tool
class_name MachineSlicable
extends Node

@export var product :PackedScene;
@export var can_be_sliced = true

func slice() -> bool:
	if can_be_sliced:
		var product_instance = product.instantiate()
		product_instance.position = get_parent().position
		get_parent().get_parent().add_child(product_instance)
		get_parent().queue_free()
		return true
	return false
