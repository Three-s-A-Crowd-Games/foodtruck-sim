extends AudioStreamPlayer3D

var was_released = true
var audio_stream = preload("res://audio/object_interaction/potato_cutter/potato_cutter-dynamic.tres")

@onready var slider := $"../SliderOrigin/InteractableSlider"

func _ready() -> void:
	get_parent().sliced.connect(_on_potato_cutter_sliced)
	slider.released.connect(_on_interactable_slider_released)
	slider.slider_limit_max_reached.connect(_on_interactable_slider_slider_limit_max_reached)
	slider.slider_moved.connect(_on_interactable_slider_slider_moved)
	stream = audio_stream


func _on_potato_cutter_sliced() -> void:
	if not playing: play()
	print("slice")
	get_stream_playback().switch_to_clip_by_name("slice")
	

func _on_interactable_slider_released(interactable: Variant) -> void:
	was_released = true
	

func _on_interactable_slider_slider_limit_max_reached() -> void:
	was_released = true
	

func _on_interactable_slider_slider_moved(position: float, offset: float) -> void:
	if was_released:
		was_released = false
		if not playing: play()
		print("begin")
		get_stream_playback().switch_to_clip_by_name("begin")
		return
	elif offset < 0:
		prints("down")
		get_stream_playback().switch_to_clip_by_name("down")
	else:
		prints("up")
		get_stream_playback().switch_to_clip_by_name("up")
		
