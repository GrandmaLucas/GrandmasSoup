extends Node3D
class_name Interactable

@export var prompt_message = "Pick up"
@export var mesh_path: NodePath
@export var destroy_on_pickup = false
@onready var mesh = get_node_or_null(mesh_path)

func _ready():
	if !mesh:
		for child in get_children():
			if child is MeshInstance3D:
				mesh = child
				break

func get_prompt():
	return prompt_message + "\n[E]"

func interact(player):
	if player.has_method("pickup_item") and mesh:
		# Pass the destroy_on_pickup value directly to pickup_item
		var result = player.pickup_item(mesh.mesh, destroy_on_pickup)
		if result:
			print("Item DESTROYED")
			queue_free()
		return result
	return false
