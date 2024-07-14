extends MenuBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/VBoxContainer/StartButton.pressed.connect(_request_scene_switch.bind(MainMenuStage.SceneType.GAME))
	$HBoxContainer/VBoxContainer/TutorialButton.pressed.connect(_request_scene_switch.bind(MainMenuStage.SceneType.TUTORIAL))
	$HBoxContainer/VBoxContainer/OptionsButton.pressed.connect(_request_scene_switch.bind(MainMenuStage.SceneType.OPTIONS))
	$HBoxContainer/VBoxContainer/AboutButton.pressed.connect(_request_scene_switch.bind(MainMenuStage.SceneType.ABOUT))
	
