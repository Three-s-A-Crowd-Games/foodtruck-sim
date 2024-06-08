extends Node3D

@export var item_scene:PackedScene
var item: XRToolsPickable
var spawn_position: Vector3

func _ready():
	spawn_position = $SpawnPosition.position
	$SpawnPosition.queue_free()
	_add_new_item()
	

func _add_new_item() -> void:
	item = item_scene.instantiate()
	item.visible = false
	add_child(item)
	for snap_zone: XRToolsSnapZone in item.find_children("*", "XRToolsSnapZone", true, false):
		snap_zone.enabled = false
	item.position = spawn_position

func _on_area_3d_body_exited(body):
	if not body is XRToolsPickable: return
	if(body == item and  not body.has_left_spawner):
		body.visible = true
		body.has_left_spawner = true
		for snap_zone: XRToolsSnapZone in body.find_children("*", "XRToolsSnapZone", true, false):
			snap_zone.enabled = true
		_add_new_item()
	
