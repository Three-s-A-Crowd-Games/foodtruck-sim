extends Food


@onready var all_fries = $fries.get_children();
@onready var raw_mat = preload("res://assets/materials/fries_raw.tres")
@onready var burned_mat = preload("res://assets/materials/fries_burnt.tres")

func _ready():
	_on_fryable_fry_status_changed(Fryable.FryStatus.RAW)

func _on_fryable_fry_status_changed(status):
	for fry in all_fries:
		match status:
			Fryable.FryStatus.RAW:
				fry.set_surface_override_material(0, raw_mat)
			Fryable.FryStatus.FRYED:
				fry.set_surface_override_material(0, null)
			Fryable.FryStatus.BURNED:
				fry.set_surface_override_material(0, burned_mat)
