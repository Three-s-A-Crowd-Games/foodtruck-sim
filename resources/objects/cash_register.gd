extends Node3D

const CASH_DRAWER_OPEN_DISTANCE := 0.265
const OPEN_SOUND_DURATION := 1.4
const CLOSE_SOUND_DURATION := 1.0
const OPEN_SOUND: AudioStream = preload("res://audio/sfx/food_prep/cash_register/cash_register_open.mp3")
const CLOSE_SOUND: AudioStream = preload("res://audio/sfx/food_prep/cash_register/cash_register_close.mp3")

var trays :Array
var is_open := false
var tween: Tween
@onready var cash_drawer_nodes: Array[Node3D] = [$cash_register/Cube_001]
@onready var audio_player := $AudioStreamPlayer3D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_move_drawer()

func _on_order_check_timer_timeout() -> void:
	#check for completed orders
	for order :Order in OrderController.cur_orders:
		for tray :Tray in trays:
			if tray.check_order(order):
				# Order is correct!
				order.tray = tray
				OrderController.finish_order(order)
				_move_drawer()

func _move_drawer() -> void:
	if tween and tween.is_running():
		await tween.finished
	if not tween or not tween.is_valid():
		tween = create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_BACK)
	var tween_duration: float
	if is_open:
		audio_player.stream = CLOSE_SOUND
		tween_duration = CLOSE_SOUND_DURATION
		tween.set_ease(Tween.EASE_OUT)
	else:
		audio_player.stream = OPEN_SOUND
		tween_duration = OPEN_SOUND_DURATION
		tween.set_ease(Tween.EASE_IN_OUT)
	for node: Node3D in cash_drawer_nodes:
		tween.tween_property(node, "position:z", node.position.z + ((int(!is_open)*2)-1) * CASH_DRAWER_OPEN_DISTANCE, tween_duration)
	tween.tween_callback(audio_player.play)
	tween.chain().tween_callback(func(): is_open = not is_open)
	

# Called when cash register is pressed
func _on_interactable_area_triggered(_input: Variant) -> void:
	if is_open: _move_drawer()


func _on_order_detection_area_body_entered(body: Node3D) -> void:
	if body is Tray:
		trays.append(body)


func _on_order_detection_area_body_exited(body: Node3D) -> void:
	if body is Tray:
		trays.erase(body)
