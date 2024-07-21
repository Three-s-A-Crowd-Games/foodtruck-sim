extends Node3D

var xr_interface: XRInterface

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
	
	var orig
	if xr_interface.is_hand_tracking_supported():
		orig = load("res://resources/xr_origin_handtracking.tscn").instantiate()
	else:
		orig = load("res://resources/xr_origin_controller.tscn").instantiate()
	add_child(orig)
	orig.position = $SpawnPoint.position
	
	var x
	for s in find_children("*", "XRToolsPickable"):
		if s.has_node("Sliceable"):
			x = s.get_node("Sliceable")
			x.set_deferred("monitoring", true)
