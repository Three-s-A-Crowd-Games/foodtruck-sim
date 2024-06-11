extends Node3D

@export var le_sauce :PackedScene

@onready var particle_spawner :GPUParticles3D = $GPUParticles3D
@onready var sauce_pump :SpringArm3D = $SaucePump
@onready var outlet :Marker3D = $SauceOutlet
var floor_sauce_timer :Timer

var just_hit :bool = false
var stack_zones_in_area :Array = []

var floor_sauce :Node3D = null

func _ready() -> void:
	floor_sauce_timer = Timer.new()
	add_child(floor_sauce_timer)
	floor_sauce_timer.one_shot = true
	floor_sauce_timer.connect("timeout", reset_floor_sauce)

func _process(delta: float) -> void:
	if(!just_hit and sauce_pump.get_hit_length() <= 0.01):
		just_hit = true
		particle_spawner.emitting = true
		sauce()
	elif(just_hit and sauce_pump.get_hit_length() > 0.01):
		just_hit = false

func sauce():
	if !stack_zones_in_area.is_empty():
		#Find Stackzone closest to outlet
		var closest_stack :BurgerStackZone = null
		var cur_closest :float
		for stack_zone :BurgerStackZone in stack_zones_in_area:
			if closest_stack == null:
				closest_stack = stack_zone
				cur_closest = stack_zone.global_position.distance_to(outlet.global_position)
				continue
			var pot_pos := stack_zone.global_position.distance_to(outlet.global_position)
			if pot_pos < cur_closest:
				closest_stack = stack_zone
				cur_closest = pot_pos
		
		# We now have our closest stack-zone. Time to give its parent some sauce
		var le_part :BurgerPart = closest_stack.get_parent()
		var le_sauce_instance = le_sauce.instantiate()
		le_sauce_instance.position = closest_stack.position
		le_part.add_child(le_sauce_instance)
		le_part.sauced = true
		
		stack_zones_in_area.erase(closest_stack)
	else:
		if floor_sauce == null:
			# Setup Floor-Sauce
			var floor_finder = $FloorFinder
			if floor_finder.is_colliding() and floor_sauce == null:
				var coll_point = floor_finder.get_collision_point()
				floor_sauce = le_sauce.instantiate()
				floor_sauce.scale *= 0.5
				add_child(floor_sauce)
				floor_sauce.visible = false
				floor_sauce.global_position = coll_point
			floor_finder.queue_free()
		
		if floor_sauce != null and floor_sauce_timer.is_stopped():
			# Floor-Sauce!
			floor_sauce.visible = true
			floor_sauce_timer.wait_time = 4
			floor_sauce_timer.start()
			print(floor_sauce_timer.is_stopped())

func reset_floor_sauce() -> void:
	floor_sauce.visible = false

func _on_sauce_area_area_entered(body: Node3D) -> void:
	if body is BurgerStackZone:
		# All EMPTY stack zones
		# That also haven't been sauced yet
		if !body.has_snapped_object() and !body.get_parent().sauced:
			stack_zones_in_area.append(body)


func _on_sauce_area_area_exited(body: Node3D) -> void:
	if body in stack_zones_in_area:
		stack_zones_in_area.erase(body)
