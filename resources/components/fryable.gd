class_name Fryable
extends Node
## The fryable component can be attached to make an object fryable

signal fry_status_changed(FryStatus)

enum FryStatus {
	RAW,
	FRYED,
	BURNED
}

## How long it takes until the connected object is done frying
@export var frying_time: float = 10.0
@export var burning_time: float = 15.0

@export var cook_sounds_stream: AudioStreamInteractive = preload("res://audio/cooking/fry/frying_audio_stream_interactive.tres")
@export var finish_sound: AudioStream
var audio_player_1: AudioStreamPlayer3D
var audio_player_2: AudioStreamPlayer3D
var fade_tweener: Tween

var time_fryed: float = 0.0
var status: FryStatus = FryStatus.RAW
var is_frying: bool = false :
	set(value):
		is_frying = value
		if value:
			self.set_process(true)
		else:
			self.set_process(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().add_to_group("fryable")
	self.set_process(false)
	if cook_sounds_stream:
		audio_player_1 = AudioStreamPlayer3D.new()
		audio_player_1.stream = cook_sounds_stream
		audio_player_1.bus = &"SFX"
		add_child(audio_player_1)
	if finish_sound:
		audio_player_2 = AudioStreamPlayer3D.new()
		audio_player_2.stream = finish_sound
		audio_player_2.bus = &"SFX"
		add_child(audio_player_2)

func _process(delta):
	time_fryed += delta
	if(status == FryStatus.RAW && time_fryed >= frying_time):
		status = FryStatus.FRYED
		fry_status_changed.emit(status)
		
		# Switch to next cooking sound and play finish sound
		if is_instance_valid(audio_player_1): audio_player_1.get_stream_playback().switch_to_clip_by_name(&"done")
		if is_instance_valid(audio_player_2):
			audio_player_2.play()
			audio_player_2.finished.connect(audio_player_2.queue_free)
		
	if(status == FryStatus.FRYED && time_fryed >= burning_time):
		status = FryStatus.BURNED
		fry_status_changed.emit(status)
		is_frying = false
		
		# Stop playing
		if is_instance_valid(audio_player_1): 
			_fade_out_audio(audio_player_1, audio_player_1.queue_free)
			

func start_frying():
	if(status != FryStatus.BURNED && !is_frying):
		is_frying = true
		
		# Start playing Sound
		if is_instance_valid(audio_player_1):
			audio_player_1.volume_db = 0
			if is_instance_valid(fade_tweener) and fade_tweener.is_running():
				fade_tweener.stop()
				fade_tweener.kill()
				fade_tweener = null
			if time_fryed == 0 and not audio_player_1.playing:
				audio_player_1.play()
			if audio_player_1.stream_paused:
				audio_player_1.stream_paused = false
			elif not audio_player_1.playing:
				var start_point = randf_range(0, audio_player_1.stream.get_length())
				audio_player_1.play(start_point)

func stop_frying():
	if(is_frying):
		is_frying = false
		
		# Stop playing sounf
		if is_instance_valid(audio_player_1):
			_fade_out_audio(audio_player_1, func(): audio_player_1.stream_paused = true)

## Fade out the stream of the given player and call on_finish after the fade out.
func _fade_out_audio(player: AudioStreamPlayer3D, on_finish: Callable):
	fade_tweener = create_tween()
	fade_tweener.finished.connect(on_finish)
	fade_tweener.tween_property(player, "volume_db", -80, 1.5).set_ease(Tween.EASE_IN)
