extends Node3D

const SOUND_ON = preload("res://audio/sfx/object_interaction/radio/radio_on.mp3")
const SOUND_OFF = preload("res://audio/sfx/object_interaction/radio/radio_off.mp3")
const ROTATION_ON = Vector3(-66.6,0,0)
const ROTATION_OFF = Vector3(-9.6,0,0)
var is_on = false
@onready var sfx_player: AudioStreamPlayer3D = $SFXPlayer
@onready var music_player: AudioStreamPlayer3D = $MusicPlayer
@onready var on_switch := $radio/Cube_002

func _ready() -> void:
	music_player.finished.connect(music_player.play)
	music_player.stream = load(MusicManager.PLAYLIST_SAVE_PATH)


func _on_interactable_area_button_button_pressed(button: Variant) -> void:
	is_on = not is_on
	if is_on:
		sfx_player.stream = SOUND_ON
		on_switch.rotation = ROTATION_ON
		sfx_player.finished.connect(music_player.play, CONNECT_ONE_SHOT)
	else:
		sfx_player.stream = SOUND_OFF
		on_switch.rotation = ROTATION_OFF
		if music_player.playing: music_player.stop()
	sfx_player.play()
