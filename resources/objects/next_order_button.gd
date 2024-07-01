extends XRToolsInteractableAreaButton

const PRESS_SOUND: AudioStream = preload("res://audio/object_interaction/order_button/order_button_pressed.mp3")
const RELEASE_SOUND: AudioStream = preload("res://audio/object_interaction/order_button/order_button_released.mp3")
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _on_button_pressed(_button: Variant) -> void:
	audio_player.stream = PRESS_SOUND
	audio_player.pitch_scale = randf_range(1,1.2)
	audio_player.play()
	var new_order = OrderController.create_new_order()
	if new_order != null:
		var new_paper = load("res://resources/objects/order_paper.tscn").instantiate()
		$Order_Paper_Spawner.add_child(new_paper)
		new_paper.set_order(new_order)
		new_order.order_paper = new_paper


func _on_button_released(_button: Variant) -> void:
	audio_player.stream = RELEASE_SOUND
	audio_player.pitch_scale = randf_range(1,1.2)
	audio_player.play()
