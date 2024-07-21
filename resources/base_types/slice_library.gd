class_name SliceLibrary
extends Resource

@export var library: Dictionary

func get_slice_mesh(type: Ingredient.Type, slice_count: int) -> Mesh:
	return library[type][slice_count][1]

func get_remain_mesh(type: Ingredient.Type, slice_count: int) -> Mesh:
	return library[type][slice_count][0]
