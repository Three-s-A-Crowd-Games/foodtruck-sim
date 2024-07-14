class_name FryingArea
extends Area3D

var fryables_inside: Array[Fryable] = []

@onready var idle_audio_player: AudioStreamPlayer3D = $IdleAudioPlayer

@export var enabled: bool = false :
	set(value):
		enabled = value
		if value:
			if fryables_inside.is_empty():
				idle_audio_player.play()
				return
			for fryable:Fryable in fryables_inside:
				fryable.start_frying()
		else:
			if idle_audio_player.playing: idle_audio_player.stop()
			for fryable:Fryable in fryables_inside:
				fryable.stop_frying()
			

# Does not always start cooking - hence an extra signal to check with the appliance
func _on_body_entered(body):
	if(body.is_in_group("fryable")):
		var fryable: Fryable = body.get_node("Fryable")
		fryables_inside.append(fryable)
		fryable.fry_status_changed.connect(_on_fry_status_changed)
		
		if enabled and fryable.status != Fryable.FryStatus.BURNED:
			fryable.start_frying();
			if idle_audio_player.playing: idle_audio_player.stop()

# Always stops cooking
func _on_body_exited(body):
	if(body.is_in_group("fryable")):
		var fryable = body.get_node("Fryable")
		fryables_inside.erase(fryable)
		fryable.stop_frying();
		if enabled  and not idle_audio_player.playing:
			for fr: Fryable in fryables_inside:
				if fr.status != Fryable.FryStatus.BURNED: return
			idle_audio_player.play()

func _on_fry_status_changed(status: Fryable.FryStatus) -> void:
	if status != Fryable.FryStatus.BURNED: return
	for fryable: Fryable in fryables_inside:
		if fryable.status != Fryable.FryStatus.BURNED: return
	idle_audio_player.play()
