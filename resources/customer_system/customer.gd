class_name Customer
extends Node3D

var wait_pos :Path3D
var can_leave := false
var waiting_pos_stop_value = 0.0
var tray :Tray = null

func randomize_appearance():
	pass

func angry():
	can_leave = true

func happy(le_tray :Node3D):
	can_leave = true
	tray = le_tray
	tray.get_parent().remove_child(tray)
	$TrayCarrier.add_child(tray)
	tray.position = Vector3(0,0,0)
