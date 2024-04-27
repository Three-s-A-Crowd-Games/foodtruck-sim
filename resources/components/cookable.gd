class_name Cookable
extends Node
## The cookable component can be attached to make an object cookable

signal cooked_status_changed(CookedStatus)

enum CookedStatus {
	RAW,
	COOKED,
	BURNED
}

## How long it takes until the connected object is done cooking
@export var cooking_time: float = 5.0
@export var burning_time: float = 10.0

var time_cooked: float = 0.0
var status: CookedStatus = CookedStatus.RAW
var is_cooking: bool = false :
	set(value):
		is_cooking = value
		if value:
			self.set_process(true)
		else:
			self.set_process(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().add_to_group("cookable")
	self.set_process(false)

func _process(delta):
	time_cooked += delta
	if(status == CookedStatus.RAW && time_cooked >= cooking_time):
		print("Cooked")
		status = CookedStatus.COOKED
		cooked_status_changed.emit(status)
	if(status == CookedStatus.COOKED && time_cooked >= burning_time):
		print("Burned")
		status = CookedStatus.BURNED
		cooked_status_changed.emit(status)
		is_cooking = false

func start_cooking():
	print("started")
	if(status != CookedStatus.BURNED && !is_cooking):
		is_cooking = true

func stop_cooking():
	print("stopped")
	if(is_cooking):
		is_cooking = false
