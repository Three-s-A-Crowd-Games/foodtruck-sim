class_name Customer
extends Node3D

var wait_pos :Path3D
var can_leave := false
var waiting_pos_stop_value = 0.0

func randomize_appearance():
	pass

func angry():
	can_leave = true

func happy():
	can_leave = true
