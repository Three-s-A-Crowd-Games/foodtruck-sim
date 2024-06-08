extends Node3D

var xr_interface: XRInterface
var order = Order.create_order()

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected")
	
	#var xr_orig = null
	#if xr_interface.is_hand_tracking_supported():
	#	XRToolsFunctionPickup.in_handtracking_mode = true
	#else:
	#	xr_orig = load("res://resources/xr_origin_controller.tscn").instantiate()
	var xr_orig = load("res://resources/xr_origin_handtracking.tscn").instantiate()
	xr_orig.transform = Transform3D(Vector3(1.31134e-07, 0, 1), Vector3(0, 1, 0), Vector3(-1, 0, 1.31134e-07), Vector3(-0.109164, 1.43315, 0.152627))
	add_child(xr_orig)
	
	printt("Main order", order.main_recipe.ingredients)
	printt("Side order", order.side_recipe.ingredients)
