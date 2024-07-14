extends Node3D

@export var is_open := false
@onready var audio_player := $InteractionSFX
@export var sound_open: AudioStream = preload("res://audio/sfx/object_interaction/fridge/fridge-open.mp3")
@export var sound_close: AudioStream = preload("res://audio/sfx/object_interaction/fridge/fridge-close.mp3")

func _on_xr_tools_interactable_hinge_hinge_moved(angle: Variant) -> void:
	if angle == 0:
		audio_player.stream = sound_close
		audio_player.play()
		is_open = false
	elif not is_open:
		audio_player.stream = sound_open
		audio_player.play()
		is_open = true
