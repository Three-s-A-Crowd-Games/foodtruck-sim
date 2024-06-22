class_name Cookable
extends Node
## The cookable component can be attached to make an object cookable

signal cooked_status_changed(CookedStatus)

enum CookedStatus {
	RAW,
	COOKED,
	BURNED
}

## How long it takes until the connected object is done cooking
@export var cooking_time: float = 5.0
@export var burning_time: float = 10.0

@export var cook_sounds_stream: AudioStreamInteractive
@export var finish_sound: AudioStream
var audio_player_1: AudioStreamPlayer3D
var audio_player_2: AudioStreamPlayer3D
var fade_tweener

var time_cooked: float = 0.0
var status: CookedStatus = CookedStatus.RAW
var is_cooking: bool = false :
	set(value):
		is_cooking = value
		if value:
			self.set_process(true)
		else:
			self.set_process(false)


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().add_to_group("cookable")
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
	time_cooked += delta
	if(status == CookedStatus.RAW && time_cooked >= cooking_time):
		status = CookedStatus.COOKED
		cooked_status_changed.emit(status)
		
		# Switch to next cooking sound and play finish sound
		if is_instance_valid(audio_player_1): audio_player_1.get_stream_playback().switch_to_clip(1)
		if is_instance_valid(audio_player_2):
			audio_player_2.play()
			audio_player_2.finished.connect(audio_player_2.queue_free)
	
	if(status == CookedStatus.COOKED && time_cooked >= burning_time):
		status = CookedStatus.BURNED
		cooked_status_changed.emit(status)
		is_cooking = false
		
		# Stop playing
		if is_instance_valid(audio_player_1): 
			_fade_out_audio(audio_player_1, audio_player_1.queue_free)

func start_cooking():
	if(status != CookedStatus.BURNED && !is_cooking):
		is_cooking = true
		
		# Start playing Sound
		if is_instance_valid(audio_player_1):
			audio_player_1.volume_db = 0
			if is_instance_valid(fade_tweener) and fade_tweener.is_running():
				fade_tweener.stop()
				fade_tweener.kill()
				fade_tweener = null
			if audio_player_1.stream_paused:
				audio_player_1.stream_paused = false
			elif not audio_player_1.playing:
				var start_point = randf_range(0, audio_player_1.stream.get_length())
				audio_player_1.play(start_point)

func stop_cooking():
	if(is_cooking):
		is_cooking = false
		
		# Stop playing sounf
		if is_instance_valid(audio_player_1):
			_fade_out_audio(audio_player_1, func(): audio_player_1.stream_paused = true)

## Fade out the stream of the given player and call on_finish after the fade out.
func _fade_out_audio(player: AudioStreamPlayer3D, on_finish: Callable):
	fade_tweener = create_tween()
	fade_tweener.finished.connect(on_finish)
	fade_tweener.tween_property(player, "volume_db", -80, 1.5).set_ease(Tween.EASE_IN)
