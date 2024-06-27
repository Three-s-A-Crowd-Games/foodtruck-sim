extends Node3D

@export var sound_on: AudioStream = preload("res://audio/object_interaction/fryer/fryer_switch_on.mp3")
@export var sound_off: AudioStream = preload("res://audio/object_interaction/fryer/fryer_switch_off.mp3")

@onready var switch_top :Node3D = $"fryer/switch-top"
@onready var frying_area: FryingArea = $FryingArea
@onready var switch_audio_player: AudioStreamPlayer3D = $InteractableAreaButton/SwitchAudioPlayer

var active :bool = false

func _on_interactable_area_button_button_pressed(button):
	active = !active
	frying_area.enabled = !frying_area.enabled
	if active:
		switch_top.rotation_degrees.x = 25
		$GPUParticles3D.emitting = true
		$GPUParticles3D2.emitting = true
		if switch_audio_player.playing: switch_audio_player.stop()
		switch_audio_player.stream = sound_on
		switch_audio_player.play()
	else:
		switch_top.rotation_degrees.x = 0
		$GPUParticles3D.emitting = false
		$GPUParticles3D2.emitting = false
		if switch_audio_player.playing: switch_audio_player.stop()
		switch_audio_player.stream = sound_off
		switch_audio_player.play()
