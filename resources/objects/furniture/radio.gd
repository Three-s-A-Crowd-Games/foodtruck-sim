extends Node3D

const SOUND_ON = preload("res://audio/sfx/object_interaction/radio/radio_on.mp3")
const SOUND_OFF = preload("res://audio/sfx/object_interaction/radio/radio_off.mp3")
const ROTATION_ON = Vector3(-66.6,0,0)
const ROTATION_OFF = Vector3(-9.6,0,0)
var is_on = false
@onready var sfx_player: AudioStreamPlayer3D = $SFXPlayer
@onready var music_player: AudioStreamPlayer3D = $MusicPlayer
@onready var on_switch := $radio/Cube_002


func _on_interactable_area_button_button_pressed(button: Variant) -> void:
	is_on = not is_on
	if is_on:
		sfx_player.stream = SOUND_ON
		on_switch.rotation = ROTATION_ON
		if music_player.stream_paused:
			music_player.stream_paused = false
		else:
			music_player.play()
		sfx_player.finished.connect(music_player.play, CONNECT_ONE_SHOT)
	else:
		sfx_player.stream = SOUND_OFF
		on_switch.rotation = ROTATION_OFF
		if music_player.playing: music_player.stream_paused = true
	sfx_player.play()


func _on_interactable_area_button_button_released(button: Variant) -> void:
	pass # Replace with function body.
