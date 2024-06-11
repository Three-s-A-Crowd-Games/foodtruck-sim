@tool
class_name MachineSlicable
extends Node

@export var product :PackedScene;

func slice():
	var product_instance = product.instantiate()
	product_instance.position = get_parent().position
	get_parent().get_parent().add_child(product_instance)
	get_parent().queue_free()
