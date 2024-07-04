class_name MainMenuStage
extends XRToolsSceneBase

enum SceneType{
	GAME,
	MAIN,
	TUTORIAL,
	OPTIONS,
	ABOUT
}

const menu_dic: Dictionary = {
	SceneType.MAIN : preload("res://resources/menus/main_menu.tscn"),
	SceneType.TUTORIAL : preload("res://resources/menus/tutorials_menu.tscn"),
	SceneType.OPTIONS : preload("res://resources/menus/options_menu.tscn"),
	SceneType.ABOUT : preload("res://resources/menus/about_menu.tscn")
	}

const MENU_SCREEN_HEIGHT := 3
const MAIN_MENU_SCREEN_HEIGHT := 1.5

@onready var menu_display := $MenuDisplay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	_switch_menu(SceneType.MAIN)


func _switch_menu(to: SceneType) -> void:
	if to == SceneType.GAME:
		load_scene("res://resources/main.tscn")
		MusicManager.create_playlist()
		return
	menu_display.set_scene(menu_dic[to])
	var menu: MenuBase = menu_display.get_scene_instance()
	var screen_width: float
	if menu:
		screen_width = menu.control_node.size.x / menu.control_node.size.y * MENU_SCREEN_HEIGHT
	else:
		push_error("Failed to switch to scene: ", SceneType.keys()[to])
		return
	menu_display.viewport_size = menu.control_node.size
	if to == SceneType.MAIN:
		menu_display.screen_size = Vector2(
			menu.control_node.size.x / menu.control_node.size.y * MAIN_MENU_SCREEN_HEIGHT,
			MAIN_MENU_SCREEN_HEIGHT)
	else:
		menu_display.screen_size = Vector2(screen_width, MENU_SCREEN_HEIGHT)
	menu_display.connect_scene_signal("scene_switch_requested", _switch_menu)
