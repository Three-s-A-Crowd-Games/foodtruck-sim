class_name Customer
extends Node3D

enum SoundType{
	SPEAK,
	ANGRY,
	HAPPY,
	SATISFIED,
	WAIT
}

enum Pitch{
	LOWEST,
	LOW,
	NORMAL,
	HIGH
}

signal speech_finished(customer: Customer)

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

var will_make_satisfaction_sound := bool(randi_range(0,1))
@onready var audio_player: AnimalesePlayer = $AnimalesePlayer
@onready var voice_pitch: Pitch = Pitch.values().pick_random()
@onready var sound_type_stream: Dictionary = CustomerVoiceProvider.get_voice_dic(voice_pitch)


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
	will_make_satisfaction_sound = false
	make_sound(SoundType.ANGRY)

func happy(le_tray :Node3D):
	make_sound(SoundType.HAPPY)
	can_leave = true
	tray = le_tray
	tray.get_parent().remove_child(tray)
	$TrayCarrier.add_child(tray)
	tray.position = Vector3(0,0,0)

func make_sound(sound_type: SoundType) -> void:
	match sound_type:
		SoundType.SPEAK:
			audio_player.stream = CustomerVoiceProvider.get_random_phrase_by_pitch(voice_pitch)
			audio_player.speak()
			audio_player.finished.connect(speech_finished.emit.bind(self), CONNECT_ONE_SHOT)
		_:
			audio_player.stream = sound_type_stream[sound_type]
			audio_player.play()
