extends MenuBase

func _ready() -> void:
	$VBoxContainer/TextureButton.pressed.connect(_request_scene_switch.bind(MainMenuStage.SceneType.MAIN))
