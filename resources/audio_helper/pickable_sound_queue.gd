@tool
class_name PickableSoundQueue3D
extends SoundQueue3D

## XRToolsPickableAudioType to associate with this pickable
@export var pickable_audio_type  : XRToolsPickableAudioType:
	set(value):
		pickable_audio_type = value
		update_configuration_warnings()

## The velocity at which the sound will be the loudest
@export var max_velocity := 6
var _original_volume: float = 0

## delta throttle is 1/10 of delta
@onready var delta_throttle : float = 0.1

@onready var _pickable : XRToolsPickable = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	var first_child = get_child(0) as AudioStreamPlayer3D
	if first_child: _original_volume = first_child.volume_db
	if Engine.is_editor_hint(): return
	# Listen for when this object enters a body
	_pickable.body_entered.connect(_on_body_entered)
	# Listen for when this object is picked up or dropped
	_pickable.picked_up.connect(_on_picked_up)
	

func _on_picked_up(_pickable: RigidBody3D) -> void:
	if not pickable_audio_type or not pickable_audio_type.grab_sound:
		return
	_next_player.volume_db = 0
	if _next_player.playing:
		_next_player.stop()
	_next_player.stream = pickable_audio_type.grab_sound
	play()


func _on_body_entered(_body):
	if not pickable_audio_type:
		return
	if _next_player.playing:
			_next_player.stop()
	if _pickable.is_picked_up() and pickable_audio_type.hit_sound:
		_next_player.stream = pickable_audio_type.hit_sound
	elif pickable_audio_type.drop_sound:
		_next_player.stream = pickable_audio_type.drop_sound
	
	var contacts = maxi(1, _pickable.get_contact_count() / 2)
	var velocity = _pickable.linear_velocity.length()
	var db = maxf(-40, linear_to_db(minf(velocity/max_velocity, 1)))
	#prints("contacts:",contacts, "\t", "velocity:", velocity, "\t", "ratio:", velocity/5,  "\t", "val:", val, "\t", "db:", db)
	for c in contacts:
		_next_player.volume_db = _original_volume + db
		play()


# This method checks for configuration issues.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	warnings += (super._get_configuration_warnings())

	if !pickable_audio_type:
		warnings.append("Pickable audio type not specified")

	# Return warnings
	return warnings
