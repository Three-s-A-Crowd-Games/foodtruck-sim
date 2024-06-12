extends Node3D

@export_enum("KETCHUP") var le_sauce_type_primitive :String = "KETCHUP"
@export var custom_bottom :PackedScene

@onready var particle_spawner :GPUParticles3D = $GPUParticles3D
@onready var sauce_pump :SpringArm3D = $SaucePump
@onready var outlet :Marker3D = $SauceOutlet
@onready var le_sauce := preload("res://assets/models/food/sauce.blend")
var floor_sauce_timer :Timer

var just_hit :bool = false
var potential_parts :Array = []

var le_sauce_type :Ingredient.Type
var floor_sauce :Node3D = null

func _ready() -> void:
	floor_sauce_timer = Timer.new()
	add_child(floor_sauce_timer)
	floor_sauce_timer.one_shot = true
	floor_sauce_timer.wait_time = 4
	floor_sauce_timer.connect("timeout", reset_floor_sauce)
	
	if custom_bottom != null:
		$sauce_container.queue_free()
		add_child(custom_bottom.instantiate())
	
	le_sauce_type = Ingredient.Type.get(le_sauce_type_primitive)
	# TODO Adjust Material of Sauce

func _process(delta: float) -> void:
	if(!just_hit and sauce_pump.get_hit_length() <= 0.01):
		just_hit = true
		particle_spawner.emitting = true
		sauce()
	elif(just_hit and sauce_pump.get_hit_length() > 0.01):
		just_hit = false

func sauce():
	if !potential_parts.is_empty():
		print("Should Sauce")
		#Find Part closest to outlet
		var closest_part :BurgerPart = null
		var cur_closest :float
		for burger_part :BurgerPart in potential_parts:
			if closest_part == null:
				closest_part = burger_part
				cur_closest = burger_part.global_position.distance_to(outlet.global_position)
				continue
			var pot_pos := burger_part.global_position.distance_to(outlet.global_position)
			if pot_pos < cur_closest:
				closest_part = burger_part
				cur_closest = pot_pos
		
		# We now have our closest stack-zone. Time to give its parent some sauce
		var le_part :BurgerPart = closest_part
		var le_sauce_instance = le_sauce.instantiate()
		le_part.add_child(le_sauce_instance)
		if closest_part.flipped_state != BurgerPart.FlipState.FLIPPED:
			le_sauce_instance.position.y = closest_part.stack_zone_distance
		else:
			le_sauce_instance.rotation_degrees.x = 180
		le_part.sauced = le_sauce_type
		
		potential_parts.erase(closest_part)
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
		
		if floor_sauce != null:
			if floor_sauce_timer.is_stopped():
				# Floor-Sauce!
				floor_sauce.visible = true
				floor_sauce_timer.start()
			else:
				# Preserve Floor-Sauce
				floor_sauce_timer.start()

func reset_floor_sauce() -> void:
	floor_sauce.visible = false

func _on_sauce_area_area_entered(area: Node3D) -> void:
	if area is BurgerStackZone:
		# All EMPTY stack zones
		# That also haven't been sauced yet
		if !area.has_snapped_object() and area.get_parent().burger_part_stack.back().sauced == -1:
			potential_parts.append(area.get_parent().burger_part_stack.back())


func _on_sauce_area_area_exited(area: Node3D) -> void:
	if area in potential_parts:
		potential_parts.erase(area)
