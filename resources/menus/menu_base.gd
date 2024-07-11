@tool
class_name MenuBase
extends CanvasLayer

signal scene_switch_requested(menu: MainMenuStage.SceneType)

const BUTTON_CLICK_SOUND: AudioStream = preload("res://audio/sfx/menu/click1.mp3")

var sfx_player: AudioStreamPlayer3D

@onready var size: Vector2 = get_child(0).size

func _request_scene_switch(to: MainMenuStage.SceneType) -> void:
	scene_switch_requested.emit(to)
	sfx_player.stream = BUTTON_CLICK_SOUND
	sfx_player.play()

func _get_configuration_warnings() -> PackedStringArray:
	var out: PackedStringArray
	
	if get_child_count() == 0:
		out.append("The menu is missing content. Please add a control node.")
	elif not get_child(0) is Control:
		out.append("First child is no control node. In order to be correctly displayed please add the control node containing the menus content as first child.")
	
	return out
