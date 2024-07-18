extends Node3D

# Ingredient type -> Slicedata
var _slice_data: Dictionary
# Ingredient type -> Slices
var slices_dic: Dictionary

const DIR := "res://resources/food/"
const DATA_FILE_PATH := "res://resources/slice_library.res"


# Called when the node enters the scene tree for the first time.
func _ready():
	_get_slice_data()

var count1 := -1
var count2 := 0
var count3 := 0
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if count1 == _slice_data.size(): return
		var size = _slice_data[_slice_data.keys()[count1]].slice_positions.size()
		if count2 == size or count1 == -1: 
			count1 += 1
			display_mesh(count1)
			$MeshInstance3D1/SliceTrans.visible = false
			count2 = 0
		else:
			if count3 % 2 == 0:
				display_trans(count1, count2)
			elif count3 % 2 == 1:
				display_slice(count1, count2)
				count2 += 1
			count3 += 1
				

func _get_slice_data() -> void:
	var file_names := DirAccess.get_files_at(DIR)
	for name in file_names:
		if not name.ends_with(".tscn"): continue
		print("loading ", name)
		var ps: PackedScene = load(DIR + name)
		var node := ps.instantiate()
		var sr := node.find_children("*", "Sliceable")
		if sr.is_empty(): continue
		var sliceable_comp: Sliceable = sr[0]
		var data: Array = sliceable_comp.get_slicing_data()
		register_sliceable(data[0], data[1], data[2], data[3], data[4])
	

func register_sliceable(type: Ingredient.Type, mesh: Mesh, mesh_node_basis: Basis, slice_positions: Array[float], cross_section_material: Material = null):
	if not mesh:
		push_error("Given mesh is null.")
		return
	if not slice_positions:
		push_error("Positions")
		return
		
	if _slice_data.has(type): return
	_slice_data.get_or_add(type, SliceData.new(mesh, mesh_node_basis, slice_positions, cross_section_material))
	

func display_mesh(idx: int) -> void:
	var type :Ingredient.Type = _slice_data.keys()[idx]
	var data: SliceData = _slice_data[type]
	$MeshInstance3D1.mesh = data.mesh
	

func display_trans(idx: int, slice_num: int) -> void:
	var type :Ingredient.Type = _slice_data.keys()[idx]
	var data: SliceData = _slice_data[type]
	var trans = _get_slice_transform(type, slice_num)
	printt(idx, slice_num, trans)
	$MeshInstance3D1/SliceTrans.visible = true
	$MeshInstance3D1/SliceTrans.transform = trans
	

func display_slice(idx: int, slice_num: int) -> void:
	var type :Ingredient.Type = _slice_data.keys()[idx]
	var data: SliceData = _slice_data[type]
	var trans = _get_slice_transform(type, slice_num)
	var slices = MeshSlicer.slice_mesh(trans, data.mesh, data.cross_ection_material)
	$MeshInstance3D2.mesh = slices[0]
	$MeshInstance3D3.mesh = slices[1]
	

func _get_slice_transform(type: Ingredient.Type, slice_num: int) -> Transform3D:
	# As far as I know the mesh slicing tool cuts along the xy-plane of the given transform.
	# The transform has to be in the local space of the mesh.
	var trans := Transform3D.IDENTITY.rotated(Vector3.UP, PI/2)
	trans.origin.x = _slice_data[type].slice_positions[slice_num]
	return trans
	

func _save_slices() -> void:
	var lib := SliceLibrary.new()
	lib.library = slices_dic
	var error := ResourceSaver.save(lib, DATA_FILE_PATH)
	if error != OK:
		print_rich("[color=red]Failed to save slicecs library. Error code: ", error, "[/color]")
	else:
		print_rich("[color=green]Successfully saved slicecs library[/color]")

class SliceData:
	var mesh: Mesh
	var mesh_node_basis: Basis
	var slice_positions: Array[float]
	var cross_ection_material: Material
	
	func _init(mesh: Mesh, mesh_node_basis: Basis, slice_positions: Array[float], cross_section_material: Material = null) -> void:
		self.mesh = mesh
		self.mesh_node_basis = mesh_node_basis
		self.slice_positions = slice_positions
		self.cross_ection_material = cross_ection_material
