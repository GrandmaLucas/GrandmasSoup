extends Node3D

@export var tree_scenes: Array[PackedScene]
@export var forest_size: Vector2 = Vector2(50, 50)
@export var tree_count: int = 100

func _ready():
	var multimesh = MultiMeshInstance3D.new()
	multimesh.multimesh = MultiMesh.new()
	multimesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.multimesh.instance_count = tree_count
	
	# First, create a reference mesh from one of the scenes
	var reference_mesh = tree_scenes[0].instantiate().mesh
	multimesh.multimesh.mesh = reference_mesh
	
	for i in tree_count:
		var scene_index = randi() % tree_scenes.size()
		var transform = Transform3D()
		
		transform.origin = Vector3(
			randf_range(-forest_size.x/2, forest_size.x/2),
			0, 
			randf_range(-forest_size.y/2, forest_size.y/2)
		)
		transform.basis = transform.basis.rotated(Vector3.UP, randf_range(0, 2*PI))
		transform.basis = transform.basis.scaled(Vector3.ONE * randf_range(0.8, 1.2))
		
		multimesh.multimesh.set_instance_transform(i, transform)
	
	add_child(multimesh)
