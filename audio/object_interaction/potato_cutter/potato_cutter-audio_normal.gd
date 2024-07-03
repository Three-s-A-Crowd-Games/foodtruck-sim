extends AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stream = preload("res://audio/object_interaction/potato_cutter/potato_cutter.mp3")
	get_parent().sliced.connect(
		func():
			if playing:
				stop()
			play())
