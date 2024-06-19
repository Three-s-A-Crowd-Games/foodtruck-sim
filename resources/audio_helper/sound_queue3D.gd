@tool
class_name SoundQueue3D
extends Node3D

signal finished

@export var player_count := 0
var count_playing: int = 0:
	set(value):
		count_playing = value
		if value == 0: finished.emit()

var _next := 0
var audioStreamPlayers: Array[AudioStreamPlayer3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var child = get_child(0)
	if child is AudioStreamPlayer3D:
		audioStreamPlayers.append(child)
		child.finished.connect(_reduce_count_playing)
		for i in range(player_count-1):
			var duplicate: AudioStreamPlayer3D = child.duplicate()
			duplicate.finished.connect(_reduce_count_playing)
			add_child(duplicate)
			audioStreamPlayers.append(duplicate)

func _reduce_count_playing() -> void:
	count_playing -= 1

func play() -> void:
	if not audioStreamPlayers[_next].playing:
		count_playing += 1
		audioStreamPlayers[_next].play()
		_next += 1
		_next %= player_count

func _get_configuration_warnings() -> PackedStringArray:
	var out: PackedStringArray
	if get_child_count() == 0:
		out.append("No children found. Expected one AudioStreamPlayer3D")
	elif get_child(0) is not AudioStreamPlayer3D:
		out.append("Expected first child to be an AudioStreamPlayer3D")
	return out
