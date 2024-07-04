@tool
class_name MenuBase
extends CanvasLayer

signal scene_switch_requested(menu: MainMenuStage.SceneType)

@onready var control_node: Control = get_child(0)

func _get_configuration_warnings() -> PackedStringArray:
	var out: PackedStringArray
	
	if get_child_count() == 0:
		out.append("The menu is missing content. Please add a control node.")
	elif not get_child(0) is Control:
		out.append("First child is no control node. In order to be correctly displayed please add the control node containing the menus content as first child.")
	
	return out
