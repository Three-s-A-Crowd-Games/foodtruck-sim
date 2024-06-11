@tool
extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var up = Vector3.UP
	var l = Vector3(-1,1,0)
	var r = Vector3(1,1,0)
	
	printt(Vector3(0.25,0,0).rotated(Vector3.FORWARD, PI/2))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
