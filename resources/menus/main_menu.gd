extends MenuBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/VBoxContainer/StartButton.pressed.connect(scene_switch_requested.emit.bind(MainMenuStage.SceneType.GAME))
	$HBoxContainer/VBoxContainer/TutorialButton.pressed.connect(scene_switch_requested.emit.bind(MainMenuStage.SceneType.TUTORIAL))
	$HBoxContainer/VBoxContainer/OptionsButton.pressed.connect(scene_switch_requested.emit.bind(MainMenuStage.SceneType.OPTIONS))
	$HBoxContainer/VBoxContainer/AboutButton.pressed.connect(scene_switch_requested.emit.bind(MainMenuStage.SceneType.ABOUT))
	
