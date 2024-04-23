class_name Cookable
extends Node
## The cookable component can be attached to make an object cookable

enum CookedStatus {
	RAW,
	COOKED,
	BURNED
}

signal cooked_status_changed(CookedStatus)

## How long it takes until the connected object is done cooking
@export var cooking_time: float = 5.0
@export var burning_time: float = 10.0

var time_cooked: float = 0.0
var status: CookedStatus = CookedStatus.RAW

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
		get_parent().queue_free()
		self.set_process(false)

func start_cooking():
	print("started")
	if(status != CookedStatus.BURNED && !self.is_processing()):
		self.set_process(true)

func stop_cooking():
	print("stopped")
	if(self.is_processing()):
		self.set_process(false)
