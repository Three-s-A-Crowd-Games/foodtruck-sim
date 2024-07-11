extends MenuBase

enum TutorialType {
	PotatoCutting,
	Slicing
}

var video_dict :Dictionary = {
	TutorialType.PotatoCutting: preload("res://assets/video/TutorialPotatoCutting.ogv"),
	TutorialType.Slicing: preload("res://assets/video/TutorialSlicing.ogv")
}

var title_dict :Dictionary = {
	TutorialType.PotatoCutting: "POTATO CUTTING",
	TutorialType.Slicing: "SLICING INGREDIENTS"
}

@onready var v_player := $"tutorial-menu/VBoxContainer/HBoxContainer/video/CenterContainer/HBoxContainer/VideoStreamPlayer" 

var current_video :TutorialType = -1

func _ready() -> void:
	$"tutorial-menu/back-button".pressed.connect(_request_scene_switch.bind(MainMenuStage.SceneType.MAIN))
	switch_tutorial(TutorialType.PotatoCutting)

func switch_tutorial(type :TutorialType) -> void:
	if sfx_player:
		sfx_player.stream = BUTTON_CLICK_SOUND
		sfx_player.play()
	if current_video == type:
		return
	if v_player.is_playing():
		v_player.stop()
		v_player.set_stream(null)
	$"tutorial-menu/VBoxContainer/Label".text = title_dict[type]
	current_video = type
	v_player.set_stream(video_dict[type])
	v_player.play()

func _on_forward():
	match (current_video):
		TutorialType.PotatoCutting:
			switch_tutorial(TutorialType.Slicing)
		_:
			switch_tutorial(TutorialType.PotatoCutting)

func _on_back():
	match (current_video):
		TutorialType.Slicing:
			switch_tutorial(TutorialType.PotatoCutting)
		_:
			switch_tutorial(TutorialType.Slicing)
