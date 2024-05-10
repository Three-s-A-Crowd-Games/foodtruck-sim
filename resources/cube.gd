class_name Cube
extends Food


var original_width: float
const slice_count := 3
var slice_positions: Array[Vector3]
var slices_left
var slice_width

func _ready():
	slices_left = slice_count
	var col_shape = $CollisionShape3D.shape
	if col_shape is SphereShape3D or col_shape is CylinderShape3D or col_shape is CapsuleShape3D:
		original_width = col_shape.radius * 2
	elif col_shape is BoxShape3D:
		original_width = col_shape.size.x
	else:
		print("Im a slice, please dont cut me")
		
	slice_width = original_width / slice_count
	for i in range(1,slice_count):
		slice_positions.push_back(Vector3(original_width - slice_width * i, 0,0))
	
	print(slice_positions)
