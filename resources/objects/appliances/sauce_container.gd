extends Node3D

@export_enum("KETCHUP","BBQ","MUSTARD") var le_sauce_type_primitive :String = "KETCHUP"

@onready var particle_spawner :GPUParticles3D = $GPUParticles3D
@onready var sauce_pump :SpringArm3D = $SaucePump
@onready var outlet :Marker3D = $SauceOutlet
@onready var le_sauce := preload("res://assets/models/food/sauce.blend")

@onready var sauce_mat :Material = load("res://assets/materials/ketchup.tres")
@onready var bottom_mat :Material = load("res://assets/materials/ketchup_container.tres")

var floor_sauce_timer :Timer

var just_hit :bool = false
var stack_zones_in_area :Array = []

var le_sauce_type :Ingredient.Type
var floor_sauce :Node3D = null

func _ready() -> void:
	floor_sauce_timer = Timer.new()
	add_child(floor_sauce_timer)
	floor_sauce_timer.one_shot = true
	floor_sauce_timer.wait_time = 4
	floor_sauce_timer.timeout.connect(reset_floor_sauce)
	
	le_sauce_type = Ingredient.Type.get(le_sauce_type_primitive)
	print(le_sauce_type)
	
	# Figure out materials
	match le_sauce_type:
		Ingredient.Type.KETCHUP:
			# Is basically default - nothing to do
			pass
		Ingredient.Type.BBQ:
			sauce_mat = load("res://assets/materials/bbq_sauce.tres")
			bottom_mat = load("res://assets/materials/bbq_container.tres")
		Ingredient.Type.MUSTARD:
			sauce_mat = load("res://assets/materials/mustard.tres")
			bottom_mat = load("res://assets/materials/mustard_container.tres")
		_:
			pass
	$sauce_container/container.set_surface_override_material(0,bottom_mat)
	$GPUParticles3D.draw_pass_1.material = sauce_mat

func _process(delta: float) -> void:
	if(!just_hit and sauce_pump.get_hit_length() <= 0.01):
		just_hit = true
		particle_spawner.emitting = true
		sauce()
	elif(just_hit and sauce_pump.get_hit_length() > 0.01):
		just_hit = false

func sauce():
	if !stack_zones_in_area.is_empty():
		#Find Part closest to outlet
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
		le_sauce_instance.get_node("sauce").set_surface_override_material(0,sauce_mat)
		le_part.add_child(le_sauce_instance)
		if le_part.flipped_state == BurgerPart.FlipState.FLIPPED:
			le_sauce_instance.rotation_degrees.x = 180
		else:
			le_sauce_instance.position.y = le_part.height
		le_part.sauced = le_sauce_type
		
		stack_zones_in_area.erase(closest_stack)
	else:
		if floor_sauce == null:
			# Setup Floor-Sauce
			var floor_finder = $FloorFinder
			if floor_finder.is_colliding() and floor_sauce == null:
				var coll_point = floor_finder.get_collision_point()
				floor_sauce = le_sauce.instantiate()
				floor_sauce.get_node("sauce").set_surface_override_material(0,sauce_mat)
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
		if !area.has_snapped_object() and area.get_parent().sauced == -1:
			stack_zones_in_area.append(area)


func _on_sauce_area_area_exited(area: Node3D) -> void:
	if area in stack_zones_in_area:
		stack_zones_in_area.erase(area)
