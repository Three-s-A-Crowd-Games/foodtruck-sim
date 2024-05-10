extends Node3D

var mesh_slicer=MeshSlicer.new()

@onready var slicer = $RigidBody3D/slicer.global_transform
@onready var slicer_2 = $RigidBody3D/slicer2.global_transform
@onready var slicer_3 = $RigidBody3D/slicer3.global_transform
@onready var slicer_4 = $RigidBody3D/slicer4.global_transform

@onready var mesh_instance = $RigidBody3D/MeshInstance3D


const SLICE_INSTANCE = preload("res://slicing test/slice_instance.tscn")
@onready var slice_instance = $slice_instance

var can_slice=true

var num = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	num=0

	
func _process(_delta):
	if(Input.is_key_pressed(KEY_U)&&can_slice):
		can_slice=false
		if(num==0):
			slicer.origin=mesh_instance.to_local(slicer.origin)
			slicer.basis.x =mesh_instance.to_local(slicer.basis.x + mesh_instance.global_position)
			slicer.basis.x =mesh_instance.to_local(slicer.basis.y + mesh_instance.global_position)
			slicer.basis.x =mesh_instance.to_local(slicer.basis.z + mesh_instance.global_position)
			
			var meshes = mesh_slicer.slice_mesh(slicer,mesh_instance.mesh)
			mesh_instance.mesh=meshes[1]
			
			var instance = SLICE_INSTANCE.instantiate()
			add_sibling(instance)
			instance.transform = slicer
			var child = instance.get_child(0)
			child.mesh=meshes[0]
			
		if(num==1):
			slicer_2.origin=mesh_instance.to_local(slicer_2.origin)
			slicer_2.basis.x =mesh_instance.to_local(slicer_2.basis.x + mesh_instance.global_position)
			slicer_2.basis.x =mesh_instance.to_local(slicer_2.basis.y + mesh_instance.global_position)
			slicer_2.basis.x =mesh_instance.to_local(slicer_2.basis.z + mesh_instance.global_position)
			
			var meshes = mesh_slicer.slice_mesh(slicer_2,mesh_instance.mesh)
			mesh_instance.mesh=meshes[1]
			
			var instance = SLICE_INSTANCE.instantiate()
			add_sibling(instance)
			instance.transform = slicer_2
			var child = instance.get_child(0)
			child.mesh=meshes[0]
		if(num==2):
			slicer_3.origin=mesh_instance.to_local(slicer_3.origin)
			slicer_3.basis.x =mesh_instance.to_local(slicer_3.basis.x + mesh_instance.global_position)
			slicer_3.basis.x =mesh_instance.to_local(slicer_3.basis.y + mesh_instance.global_position)
			slicer_3.basis.x =mesh_instance.to_local(slicer_3.basis.z + mesh_instance.global_position)
			
			var meshes = mesh_slicer.slice_mesh(slicer_3,mesh_instance.mesh)
			mesh_instance.mesh=meshes[1]
			
			var instance = SLICE_INSTANCE.instantiate()
			add_sibling(instance)
			instance.transform = slicer_3
			var child = instance.get_child(0)
			child.mesh=meshes[0]
		if(num==3):
			slicer_4.origin=mesh_instance.to_local(slicer_4.origin)
			slicer_4.basis.x =mesh_instance.to_local(slicer_4.basis.x + mesh_instance.global_position)
			slicer_4.basis.x =mesh_instance.to_local(slicer_4.basis.y + mesh_instance.global_position)
			slicer_4.basis.x =mesh_instance.to_local(slicer_4.basis.z + mesh_instance.global_position)
			
			var meshes = mesh_slicer.slice_mesh(slicer_4,mesh_instance.mesh)
			mesh_instance.mesh=meshes[1]
			
			var instance = SLICE_INSTANCE.instantiate()
			add_sibling(instance)
			instance.transform = slicer_4
			var child = instance.get_child(0)
			child.mesh=meshes[0]
		
		
		await get_tree().create_timer(0.2).timeout
		if(num <= 2):
			num = num + 1
		can_slice=true
		
			
