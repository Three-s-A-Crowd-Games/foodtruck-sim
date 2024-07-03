extends Node3D

@export var item_scene:PackedScene
var items: Array

func _ready():
	for marker in find_children("*", "Marker3D", true, false):
		_add_new_item(marker.position)
		marker.queue_free()
	

func _add_new_item(pos :Vector3) -> void:
	var cur_item = item_scene.instantiate()
	cur_item.visible = false
	add_child(cur_item)
	for snap_zone: XRToolsSnapZone in cur_item.find_children("*", "XRToolsSnapZone", true, false):
		snap_zone.enabled = false
	cur_item.position = pos
	items.append(cur_item)

func _on_area_3d_body_exited(body):
	if not body is XRToolsPickable: return
	body = body as XRToolsPickable
	if(body in items and  not body.has_left_spawner):
		items.erase(body)
		body.visible = true
		body.has_left_spawner = true
		for snap_zone: XRToolsSnapZone in body.find_children("*", "XRToolsSnapZone", true, false):
			snap_zone.enabled = true
		_add_new_item(to_local(body.transform_before_pickup.origin))
	
