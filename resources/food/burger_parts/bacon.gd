extends BurgerPart

var raw_mat = preload("res://assets/materials/bacon_raw.tres")
var cooked_mat = preload("res://assets/materials/bacon_cooked.tres")
var burned_mat = preload("res://assets/materials/bacon_burned.tres")

func _on_cookable_cooked_status_changed(status):
	match status:
		Cookable.CookedStatus.RAW:
			$bacon/Plane.set_surface_override_material(0, raw_mat)
		Cookable.CookedStatus.COOKED:
			$bacon/Plane.set_surface_override_material(0, cooked_mat)
		Cookable.CookedStatus.BURNED:
			$bacon/Plane.set_surface_override_material(0, burned_mat)
