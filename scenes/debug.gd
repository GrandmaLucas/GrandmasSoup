extends Node

func _ready():
	print("Scene Debug Info:")
	var ray = get_tree().get_first_node_in_group("interaction_ray")
	if ray:
		print("RayCast found")
		print("- Enabled: ", ray.enabled)
		print("- Target Position: ", ray.target_position)
		print("- Collision Mask: ", ray.collision_mask)
	else:
		print("No RayCast found!")
		
	var interactables = get_tree().get_nodes_in_group("interactable")
	print("Found ", interactables.size(), " interactables")
