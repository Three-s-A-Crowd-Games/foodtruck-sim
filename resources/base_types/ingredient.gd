@static_unload
class_name Ingredient
extends RefCounted


enum Category{
	BURGER_PART,
	FRIES,
	DRINKS,
	SAUCES
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
	WATER,
	COKE,
	FANTA,
	ORANGE_JUICE,
	GREEN_JUICE,
	PINK_JUICE,
	KETCHUP,
	BBQ,
	MUSTARD,
}

enum Constraints{
	POSITION,
	MAX_USE,
	NO_DOUBLE_STACK
}

static var ingredients: Dictionary = {
	Type.BUN_TOP : {
		Category : Category.BURGER_PART,
		Constraints.POSITION : -1,
		Constraints.MAX_USE : 1
		},
	Type.BUN_BOTTOM : {
		Category : Category.BURGER_PART,
		Constraints.POSITION : 0,
		Constraints.MAX_USE : 1
		},
	Type.PATTY : {
		Category : Category.BURGER_PART
		},
	Type.CHEESE : {
		Category : Category.BURGER_PART
		},
	Type.LETTUCE : {
		Category : Category.BURGER_PART
		},
	Type.ONION : {
		Category : Category.BURGER_PART
		},
	Type.CUCUMBER : {
		Category : Category.BURGER_PART
		},
	Type.TOMATO : {
		Category : Category.BURGER_PART
		},
	Type.FRIES : {
		Category : Category.FRIES
		},
	Type.WATER: {
		Category : Category.DRINKS
	},
	Type.COKE: {
		Category : Category.DRINKS
	},
	Type.FANTA: {
		Category : Category.DRINKS
	},
	Type.ORANGE_JUICE: {
		Category : Category.DRINKS
	},
	Type.GREEN_JUICE: {
		Category : Category.DRINKS
	},
	Type.PINK_JUICE: {
		Category : Category.DRINKS
	},
	Type.KETCHUP: {
		Category : Category.SAUCES
	},
	Type.BBQ: {
		Category : Category.SAUCES
	},
	Type.MUSTARD: {
		Category : Category.SAUCES
	},
}

static var categories: Dictionary = {
	Category.BURGER_PART : {
		Type : [Type.BUN_TOP, Type.BUN_BOTTOM, Type.PATTY, Type.ONION, Type.CHEESE, Type.CUCUMBER, Type.TOMATO, Type.LETTUCE]
	},
	Category.FRIES : {
		Type : [Type.FRIES]
	},
	Category.DRINKS : {
		Type : [Type.WATER, Type.COKE, Type.FANTA, Type.ORANGE_JUICE, Type.GREEN_JUICE, Type.PINK_JUICE]
	},
	Category.SAUCES : {
		Type : [Type.KETCHUP, Type.BBQ, Type.MUSTARD],
		Constraints.NO_DOUBLE_STACK : true
	}
}

static func parse_ingridient_list(le_array :Array) -> String: #Alda was is Godoooo für ne Language.
	# Oder halt GDScript is mir doch Schnuppe (~ Henry)
	var le_string :String = ""
	for ingr in le_array:
		le_string += Ingredient.Type.keys()[ingr] + ", "
	
	return "[" + le_string.substr(0,le_string.length() - 2) + "]"
