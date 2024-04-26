class_name Order
extends RefCounted

var main_recipe: Array[Ingredient.Main]
var side_recipe: Array[Ingredient.Side]

static func create_order() -> Order:
	
