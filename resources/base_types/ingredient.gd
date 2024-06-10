@static_unload
class_name Ingredient
extends RefCounted


enum Category{
	BURGER_PART,
	FRIES
}

enum Type{
	BUN_TOP,
	BUN_BOTTOM,
	PATTY,
	FRIES,
	POTATO
}

enum Constraints{
	POSITION
}

static var ingredients: Dictionary = {
	Type.BUN_TOP : {
		Category : [Category.BURGER_PART],
		Constraints.POSITION : -1
		},
	Type.BUN_BOTTOM : {
		Category : [Category.BURGER_PART],
		Constraints.POSITION : 0
		},
	Type.PATTY : {
		Category : [Category.BURGER_PART]
		},
	Type.FRIES : {
		Category : [Category.FRIES]
		}
}

static var categories: Dictionary = {
	Category.BURGER_PART : [Type.BUN_TOP, Type.BUN_BOTTOM, Type.PATTY],
	Category.FRIES : [Type.FRIES]
}
