class_name Cookable
extends Node
## The cookable component can be attached to make an object cookable

signal started_cooking
signal finished_cooking

## How long it takes until the connected object is done cooking
@export var cooking_time: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().add_to_group("cookable")
