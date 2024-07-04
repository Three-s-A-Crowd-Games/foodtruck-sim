extends XRToolsSceneBase


func _ready():
	super._ready()

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("ui_accept")):
		load_scene("res://resources/main_menu.tscn")


func _on_back_to_menu_button_back_to_menu_requested():
	exit_to_main_menu()
