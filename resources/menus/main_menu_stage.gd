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

var size := {}

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
	if size.has(to):
		menu_display.viewport_size = size[to]
		menu_display.screen_size = Vector2(size[to].x / size[to].y * MENU_SCREEN_HEIGHT, MENU_SCREEN_HEIGHT)
	menu_display.set_scene(menu_dic[to])
	var menu: MenuBase = menu_display.get_scene_instance()
	var screen_width: float
	if menu:
		screen_width = menu.size.x / menu.size.y * MENU_SCREEN_HEIGHT
	else:
		push_error("Failed to switch to scene: ", SceneType.keys()[to])
		return
	printt(SceneType.keys()[to], menu, menu.size)
	if not size.has(to):
		size[to] = menu.size
		menu_display.viewport_size = menu.size
		menu_display.screen_size = Vector2(screen_width, MENU_SCREEN_HEIGHT)
	menu_display.connect_scene_signal("scene_switch_requested", _switch_menu)
