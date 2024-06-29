class_name Customer
extends Node3D

const Colors := [
	Color("00B3E7"), #Standard Blue
	Color("0B00FF"), #Deep Blue
	Color("5300A4"), #Lila
	Color("FF3E00"), #Orange
	Color("00FFA1"), #Türkis
	Color("FF00EB"), #Pink
	Color("00E700"), #Green
	Color("FFFFFF"), #White
	]

const Accessoires := [
	null,
	preload("res://assets/models/accessoires/schnelle_brille.blend"),
	preload("res://assets/models/accessoires/prop_hat.blend"),
]

var wait_pos :Path3D
var can_leave := false
var waiting_pos_stop_value = 0.0
var tray :Tray = null

func randomize_appearance():
	var main_mat := StandardMaterial3D.new()
	main_mat.albedo_color = Colors.pick_random()
	$customer/Cone.set_surface_override_material(0, main_mat)
	
	var acc_raw = Accessoires.pick_random()
	var acc = null
	if acc_raw != null: acc = acc_raw.instantiate()
	if acc != null: $customer.add_child(acc)

func angry():
	can_leave = true

func happy(le_tray :Node3D):
	can_leave = true
	tray = le_tray
	tray.get_parent().remove_child(tray)
	$TrayCarrier.add_child(tray)
	tray.position = Vector3(0,0,0)
