class_name DeletingArea
extends Area3D

@export_enum("ON_ENTER", "ON_EXIT") var detect_mode = "ON_ENTER"

func _ready() -> void:
	if detect_mode == "ON_ENTER":
		body_entered.connect(_on_area_3d_triggered)
	else:
		body_exited.connect(_on_area_3d_triggered)
	monitorable = false
	collision_layer = 0
	collision_mask = pow(2,2) + pow(2,16)

func _on_area_3d_triggered(body):
	if(body.is_in_group("consumables")):
		body.queue_free()
	elif(body.is_in_group("appliances")):
		body = body as XRToolsPickable
		body.global_transform = body.transform_before_pickup
