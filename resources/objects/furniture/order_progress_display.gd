class_name OrderProgressDisplay
extends MarginContainer

@onready var le_bar := $CenterContainer/HBoxContainer/TextureProgressBar

var timer :Timer = null

func _process(delta: float) -> void:
	if timer != null:
		le_bar.set_value(timer.time_left)

func setup(le_order :Order):
	#Text
	var order_num :String
	if(str(le_order.number).length() < 2):
		order_num = "#0"+str(le_order.number)
	else:
		order_num = "#"+str(le_order.number)
	$CenterContainer/HBoxContainer/Label.text = order_num
	
	#Timer
	timer = le_order.le_timer
	le_bar.set_max(timer.wait_time)
	le_bar.set_value(timer.time_left)
	
