extends Node3D

@export var sound_on: AudioStream = preload("res://audio/object_interaction/knob/knob-on.mp3")
@export var sound_off: AudioStream = preload("res://audio/object_interaction/knob/knob-off.mp3")

@onready var knob_model: MeshInstance3D  = $"stove-v2/knob"
@onready var cooking_area: CookingArea = $CookingArea
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _on_toggle_stove(stove_on :bool):
	if(stove_on):
		knob_model.rotation_degrees.z = 90
		if audio_player.playing: audio_player.stop()
		audio_player.stream = sound_on
		audio_player.play()
	else:
		knob_model.rotation_degrees.z = 0
		if audio_player.playing: audio_player.stop()
		audio_player.stream = sound_off
		audio_player.play()
	cooking_area.enabled = !cooking_area.enabled
