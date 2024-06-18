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

static var Order_Paper_Tex :String

static var ingredients: Dictionary = {
	Type.BUN_TOP : {
		Category : Category.BURGER_PART,
		Constraints.POSITION : -1,
		Constraints.MAX_USE : 1,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/top_bun.png"
		},
	Type.BUN_BOTTOM : {
		Category : Category.BURGER_PART,
		Constraints.POSITION : 0,
		Constraints.MAX_USE : 1,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/bottom_bun.png"
		},
	Type.PATTY : {
		Category : Category.BURGER_PART,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/patty.png"
		},
	Type.CHEESE : {
		Category : Category.BURGER_PART,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/cheese.png"
		},
	Type.LETTUCE : {
		Category : Category.BURGER_PART,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/lettuce.png"
		},
	Type.ONION : {
		Category : Category.BURGER_PART,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/onion.png"
		},
	Type.CUCUMBER : {
		Category : Category.BURGER_PART,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/cucumber.png"
		},
	Type.TOMATO : {
		Category : Category.BURGER_PART,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/tomato.png"
		},
	Type.FRIES : {
		Category : Category.FRIES,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/fries.png"
		},
	Type.WATER: {
		Category : Category.DRINKS,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/water.png"
	},
	Type.COKE: {
		Category : Category.DRINKS,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/coke.png"
	},
	Type.FANTA: {
		Category : Category.DRINKS,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/fanta.png"
	},
	Type.ORANGE_JUICE: {
		Category : Category.DRINKS,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/orange_juice.png"
	},
	Type.GREEN_JUICE: {
		Category : Category.DRINKS,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/green_juice.png"
	},
	Type.PINK_JUICE: {
		Category : Category.DRINKS,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/pink_juice.png"
	},
	Type.KETCHUP: {
		Category : Category.SAUCES,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/ketchup.png"
	},
	Type.BBQ: {
		Category : Category.SAUCES,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/bbq_sauce.png"
	},
	Type.MUSTARD: {
		Category : Category.SAUCES,
		Order_Paper_Tex: "res://assets/2d_images/order_paper/mustard.png"
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

static func parse_ingredient_list(le_array :Array) -> String: #Alda was is Godoooo für ne Language.
	# Oder halt GDScript is mir doch Schnuppe (~ Henry)
	var le_string :String = ""
	for ingr in le_array:
		le_string += Ingredient.Type.keys()[ingr] + ", "
	
	return "[" + le_string.substr(0,le_string.length() - 2) + "]"
