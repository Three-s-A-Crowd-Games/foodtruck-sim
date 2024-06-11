extends Node3D

var just_hit :bool = false


func _process(delta: float) -> void:
	if(!just_hit and $SpringArm3D.get_hit_length() <= 0.01):
		just_hit = true
		$GPUParticles3D.emitting = true
	elif(just_hit and $SpringArm3D.get_hit_length() > 0.01):
		just_hit = false
