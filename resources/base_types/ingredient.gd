@static_unload
class_name Ingredient
extends RefCounted


enum Category{
	BURGER_PART,
	FRIES,
	DRINKS
}

enum Type{
	BUN_TOP,
	BUN_BOTTOM,
	PATTY,
	FRIES,
	TOMATO,
	POTATO,
	LETTUCE,
	CHEESE,
	ONION,
	CUCUMBER,
	WATER
}

enum Constraints{
	POSITION,
	MAX_USE
}

static var ingredients: Dictionary = {
	Type.BUN_TOP : {
		Category : [Category.BURGER_PART],
		Constraints.POSITION : -1,
		Constraints.MAX_USE : 1
		},
	Type.BUN_BOTTOM : {
		Category : [Category.BURGER_PART],
		Constraints.POSITION : 0,
		Constraints.MAX_USE : 1
		},
	Type.PATTY : {
		Category : [Category.BURGER_PART]
		},
	Type.CHEESE : {
		Category : [Category.BURGER_PART]
		},
	Type.LETTUCE : {
		Category : [Category.BURGER_PART]
		},
	Type.ONION : {
		Category : [Category.BURGER_PART]
		},
	Type.CUCUMBER : {
		Category : [Category.BURGER_PART]
		},
	Type.TOMATO : {
		Category : [Category.BURGER_PART]
		},
	Type.FRIES : {
		Category : [Category.FRIES]
		},
	Type.WATER: {
		Category : [Category.DRINKS]
	}
}

static var categories: Dictionary = {
	Category.BURGER_PART : [Type.BUN_TOP, Type.BUN_BOTTOM, Type.PATTY, Type.ONION, Type.CHEESE, Type.CUCUMBER, Type.TOMATO, Type.LETTUCE],
	Category.FRIES : [Type.FRIES],
	Category.DRINKS : [Type.WATER]
}

static func parse_ingridient_list(le_array :Array) -> String: #Alda was is Godoooo für ne Language.
	# Oder halt GDScript is mir doch Schnuppe (~ Henry)
	var le_string :String = ""
	for ingr in le_array:
		le_string += Ingredient.Type.keys()[ingr] + ", "
	
	return "[" + le_string.substr(0,le_string.length() - 2) + "]"
