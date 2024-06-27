class_name Fryable
extends Node
## The fryable component can be attached to make an object fryable

signal fry_status_changed(FryStatus)

enum FryStatus {
	RAW,
	FRYED,
	BURNED
}

## How long it takes until the connected object is done frying
@export var frying_time: float = 5.0
@export var burning_time: float = 10.0

var time_fryed: float = 0.0
var status: FryStatus = FryStatus.RAW
var is_frying: bool = false :
	set(value):
		is_frying = value
		if value:
			self.set_process(true)
		else:
			self.set_process(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().add_to_group("fryable")
	self.set_process(false)

func _process(delta):
	time_fryed += delta
	if(status == FryStatus.RAW && time_fryed >= frying_time):
		status = FryStatus.FRYED
		fry_status_changed.emit(status)
	if(status == FryStatus.FRYED && time_fryed >= burning_time):
		status = FryStatus.BURNED
		fry_status_changed.emit(status)
		is_frying = false

func start_frying():
	if(status != FryStatus.BURNED && !is_frying):
		is_frying = true

func stop_frying():
	if(is_frying):
		is_frying = false
