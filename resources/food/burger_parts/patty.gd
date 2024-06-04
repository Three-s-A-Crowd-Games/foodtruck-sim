extends BurgerPart

var cooked_mat = preload("res://assets/materials/patty_cooked.tres")
var burned_mat = preload("res://assets/materials/patty_burned.tres")

func _on_cookable_cooked_status_changed(status):
	match status:
		Cookable.CookedStatus.RAW:
			pass
		Cookable.CookedStatus.COOKED:
			$Patty/Circle.set_surface_override_material(0, cooked_mat)
		Cookable.CookedStatus.BURNED:
			$Patty/Circle.set_surface_override_material(0, burned_mat)
