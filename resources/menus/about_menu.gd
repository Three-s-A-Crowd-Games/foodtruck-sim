extends MenuBase

func _ready() -> void:
	$VBoxContainer/TextureButton.pressed.connect(scene_switch_requested.emit.bind(MainMenuStage.SceneType.MAIN))
