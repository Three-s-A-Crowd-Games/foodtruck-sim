extends MenuBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/StartButton.pressed.connect(scene_switch_requested.emit.bind(MainMenuStage.SceneType.GAME))
	$VBoxContainer/TutorialButton.pressed.connect(scene_switch_requested.emit.bind(MainMenuStage.SceneType.TUTORIAL))
	$VBoxContainer/OptionsButton.pressed.connect(scene_switch_requested.emit.bind(MainMenuStage.SceneType.OPTIONS))
	$VBoxContainer/AboutButton.pressed.connect(scene_switch_requested.emit.bind(MainMenuStage.SceneType.ABOUT))
	
