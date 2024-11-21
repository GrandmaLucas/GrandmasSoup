extends Node3D
class_name Interactable

@export var prompt_message = "Pick up"
@export var mesh_path: NodePath
@export var destroy_on_pickup = false
@export var item_id: String = "tomato"  # Default to tomato
@export var item_type: ItemType
@onready var mesh = get_node_or_null(mesh_path)

var is_focused = false

func focus(_player):
	is_focused = true
	pass

func unfocus():
	is_focused = false
	pass

func _ready():
	if !mesh:
		for child in get_children():
			if child is MeshInstance3D:
				mesh = child
				break
	# Get the vegetable type from the database
	item_type = ItemDatabase.get_item_type(item_id)
	if item_type:
		print("Initialized as: ", item_type.display_name)

func get_prompt():
	if item_type:
		return "Grab " + item_type.display_name + "\n[E]"
	return prompt_message + "\n[E]"

func interact(player):
	if player.has_method("pickup_item") and mesh and item_type:
		var result = player.pickup_item(mesh.mesh, destroy_on_pickup, item_type)
		if result:
			print("Picked up " + item_type.display_name)
			queue_free()
		return result
	return false
