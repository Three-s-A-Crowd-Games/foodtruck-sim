@tool
class_name SliceManager
extends EditorScript

# Ingredient type -> Slicedata
static var _slice_data: Dictionary
# Ingredient type -> Slices
static var slices_dic: Dictionary

const DIR := "res://resources/food/"
const DATA_FILE_PATH := "res://resources/slice_library.res"

func _run():
	_get_slice_data()
	printt("Slice data size", _slice_data.size())
	slice_all()
	print("-------------------")
	print(slices_dic)
	print()
	_save_slices()
	print("Is da? ", FileAccess.file_exists(DATA_FILE_PATH))
	var x = load(DATA_FILE_PATH) as SliceLibrary
	print(x.library)
	

static func _get_slice_data() -> void:
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
	

static func register_sliceable(type: Ingredient.Type, mesh: Mesh, mesh_node_basis: Basis, slice_positions: Array[float], cross_section_material: Material = null):
	if not mesh:
		push_error("Given mesh is null.")
		return
	if not slice_positions:
		push_error("Positions")
		return
		
	if _slice_data.has(type): return
	_slice_data.get_or_add(type, SliceData.new(mesh, mesh_node_basis, slice_positions, cross_section_material))
	

static func slice_all() -> void:
	for i in _slice_data.size():
		slice_mesh(i)

static func slice_mesh(idx: int) -> void:
	var type :Ingredient.Type = _slice_data.keys()[idx]
	print("slice mesh: ", Ingredient.Type.keys()[type])
	var data: SliceData = _slice_data[type]
	var slices: Array[Array] = []
	slices.resize(data.slice_positions.size())
	
	var base_mesh: Mesh = data.mesh
	for slice_num: int in data.slice_positions.size():
		var trans = _get_slice_transform(type, slice_num)
		slices[slice_num] = MeshSlicer.slice_mesh(trans, base_mesh, data.cross_ection_material)
		base_mesh = slices[slice_num][0]
	
	slices_dic.get_or_add(type, slices)
	print("slice mesh finished: ", Ingredient.Type.keys()[type])

static func _get_slice_transform(type: Ingredient.Type, slice_num: int) -> Transform3D:
	# As far as I know the mesh slicing tool cuts along the xy-plane of the given transform.
	# The transform has to be in the local space of the mesh.
	var trans := Transform3D.IDENTITY.rotated(Vector3.UP, PI/2)
	trans.origin.x = _slice_data[type].slice_positions[slice_num]
	return trans
	

static func _save_slices() -> void:
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
		
