class_name OrderProgressDisplay
extends MarginContainer

signal time_low

const colors = [
	Color("#00FF3F"), #Green
	Color("#E7D300"), #Orange
	Color("#E70031") #Red
]

@export_range(0,1) var first_threshold = 0.5
@export_range(0,1) var second_threshold = 0.2

@onready var le_bar := $CenterContainer/HBoxContainer/TextureProgressBar

var timer :Timer = null
var is_first_threshold_breached := false

func _process(delta: float) -> void:
	if timer != null:
		le_bar.set_value(timer.time_left)
		
		var percent = timer.time_left / timer.wait_time
		var col_should :Color = colors[0]
		if (percent <= second_threshold):
			col_should = colors[2]
		elif (percent <= first_threshold):
			if not is_first_threshold_breached:
				time_low.emit()
				is_first_threshold_breached = true
			col_should = colors[1]
		
		if(le_bar.tint_progress != col_should):
			le_bar.tint_progress = col_should

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
	
