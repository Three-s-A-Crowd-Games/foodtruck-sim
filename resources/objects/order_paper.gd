class_name OrderPaper
extends XRToolsPickable

@onready var main_layout = $OrderViewport/PaperLayout/MainLayout
@onready var order_number = $OrderViewport/PaperLayout/CenterTitle/OrderNumber
@onready var side_tex = $OrderViewport/PaperLayout/CenterExtras/ExtrasContainer/SideTex
@onready var drink_tex = $OrderViewport/PaperLayout/CenterExtras/ExtrasContainer/DrinkTex
@onready var pin_sound_player = $AudioStreamPlayer3D

const pin_sound: AudioStream = preload("res://audio/object_interaction/order_paper_pin/pin_order_paper.mp3")
const unpin_sound: AudioStream = preload("res://audio/object_interaction/order_paper_pin/unpin_order_paper.mp3")

const NORMAL_VIEWPORT_SIZE := 650
var order :Order
var in_pinning_zone :bool = false

func set_order(le_order :Order):
	# First lets set the order number
	order = le_order
	var order_num :String
	if(str(le_order.number).length() < 2):
		order_num = "#0"+str(le_order.number)
	else:
		order_num = "#"+str(le_order.number)
	order_number.text = order_num
	
	#Main
	if(!le_order.main_recipe.ingredients.is_empty()):
		var ingr_list_rev = le_order.main_recipe.ingredients
		ingr_list_rev.reverse()
		for ingr in ingr_list_rev:
			var path_to_tex = Ingredient.ingredients[ingr].get(Ingredient.Order_Paper_Tex)
			var new_rect = TextureRect.new()
			
			new_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			new_rect.texture = load(path_to_tex)
			
			main_layout.add_child(new_rect)
	
	#Side
	if(!le_order.side_recipe.ingredients.is_empty()):
		var path_to_tex = Ingredient.ingredients[le_order.side_recipe.ingredients[0]].get(Ingredient.Order_Paper_Tex)
		side_tex.texture = load(path_to_tex)
	
	#Drink
	if(!le_order.drink_recipe.ingredients.is_empty()):
		var path_to_tex = Ingredient.ingredients[le_order.drink_recipe.ingredients[0]].get(Ingredient.Order_Paper_Tex)
		drink_tex.texture = load(path_to_tex)
	
	#Activate Dividers
	if(!le_order.side_recipe.ingredients.is_empty() or !le_order.drink_recipe.ingredients.is_empty()):
		$OrderViewport/PaperLayout/CenterExtras/ExtrasContainer.visible = true
		$OrderViewport/PaperLayout/ExtrasDivider.visible = true
		
	
	#Sizing
	if($OrderViewport/PaperLayout.get_combined_minimum_size().y > NORMAL_VIEWPORT_SIZE):
		var new_size = $OrderViewport/PaperLayout.get_combined_minimum_size().y
		$Sprite3D.offset.y = new_size * -1
		$OrderViewport.size.y = new_size
		
		var viewport_orig_size = NORMAL_VIEWPORT_SIZE * $Sprite3D.pixel_size
		var viewport_size = new_size * $Sprite3D.pixel_size
		var paper_size_before = $order_paper/Paper_001.get_aabb().size.z
		var paper_scale = viewport_size / viewport_orig_size
		$order_paper/Paper_001.scale.z = paper_scale
		$order_paper/Paper_001.position.z = (paper_size_before * paper_scale - paper_size_before) / 2
		$CollisionShape3D.scale.z = paper_scale
		$CollisionShape3D.position.z = (paper_size_before * paper_scale - paper_size_before) / 2


# Handle Pinning
func pick_up(by: Node3D) -> void:
	$PinJoint3D.node_b = NodePath("")
	super.pick_up(by)

func let_go(by: Node3D, p_linear_velocity: Vector3, p_angular_velocity: Vector3) -> void:
	super.let_go(by, p_linear_velocity, p_angular_velocity)
	if in_pinning_zone:
		$PinJoint3D.node_b = self.get_path()

func _on_pin_area_entered(area: Area3D) -> void:
	if area.is_in_group("pinning_zone"):
		$order_paper/Pin.set_surface_override_material(1,load("res://assets/materials/pin_green.tres"))
		in_pinning_zone = true
		pin_sound_player.stream = pin_sound
		pin_sound_player.play()

func _on_pin_area_exited(area: Area3D) -> void:
	if area.is_in_group("pinning_zone"):
		$order_paper/Pin.set_surface_override_material(1,load("res://assets/materials/pin_red.tres"))
		in_pinning_zone = false
		pin_sound_player.stream = unpin_sound
		pin_sound_player.play()
