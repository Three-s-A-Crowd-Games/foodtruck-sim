class_name OrderProgressDisplay
extends MarginContainer

const colors = [
	Color("#00FF3F"), #Green
	Color("#E7D300"), #Orange
	Color("#E70031") #Red
]

@onready var le_bar := $CenterContainer/HBoxContainer/TextureProgressBar

var timer :Timer = null

func _process(delta: float) -> void:
	if timer != null:
		le_bar.set_value(timer.time_left)
		
		var percent = timer.time_left / timer.wait_time
		var col_should :Color = colors[0]
		if (percent <= 0.3):
			col_should = colors[1]
		if (percent <= 0.15):
			col_should = colors[2]
		
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
	
