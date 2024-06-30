class_name AnimalesePlayer
extends AudioStreamPlayer3D

func speak(from: float = 0.0) -> void:
	super.play(from)
	get_tree().create_timer(stream.get_length()).timeout.connect(finished.emit)
