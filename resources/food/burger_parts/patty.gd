extends Food




func _on_cookable_cooked_status_changed(status):
	match status:
		Cookable.CookedStatus.RAW:
			pass
		Cookable.CookedStatus.COOKED:
			var mat = $Patty/Circle.get_surface_override_material(0)
			mat.albedo_color = Color("4e0006")
		Cookable.CookedStatus.BURNED:
			var mat = $Patty/Circle.get_surface_override_material(0)
			mat.albedo_color = Color("000000")
