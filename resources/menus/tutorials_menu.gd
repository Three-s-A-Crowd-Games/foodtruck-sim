extends MenuBase

func _ready() -> void:
	$"tutorial-menu/back-button".pressed.connect(scene_switch_requested.emit.bind(MainMenuStage.SceneType.MAIN))
