extends XRToolsPickable

@onready var main_layout = $OrderViewport/OrderContainer/PaperLayout/MainLayout
@onready var order_number = $OrderViewport/OrderContainer/PaperLayout/CenterContainer/OrderNumber

func set_order(le_order :Order):
	# First lets set the order number
	var order_num :String
	if(str(le_order.number).length() < 2):
		order_num = "#0"+str(le_order.number)
	else:
		order_num = "#"+str(le_order.number)
	order_number.text = order_num
