extends AudioStreamPlayer3D

@onready var play_back: AudioStreamPlaybackInteractive = get_stream_playback()

func _on_timer_timeout() -> void:
	var i = randi_range(0,1)
	get_stream_playback().switch_to_clip(i)
	$Timer.wait_time = randi_range(30,60)
