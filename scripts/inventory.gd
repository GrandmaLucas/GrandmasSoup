extends Node3D

@onready var item_placement: Node3D = $ItemPlacement
@onready var hands: Node3D = $ItemPlacement/Hands
@export var inventory_limit = 3
var held_items = []
var current_item = null
@onready var pickup_sfx: AudioStreamPlayer = $PickupSFX
@onready var swallow_sfx: AudioStreamPlayer = $SwallowSFX

var layout_transforms = {
	1: {  # One item
		0: {
			"position": Vector3(0, 0, 0),
			"rotation": Vector3(0, 0, 0),
		}
	},
	2: {  # Two items
		0: {
			"position": Vector3(-0.025, 0, 0),
			"rotation": Vector3(0, 0, 0),
		},
		1: {
			"position": Vector3(0.025, 0, 0),
			"rotation": Vector3(0, 0, 0),
		}
	},
	3: {  # Three items in triangle formation
		0: {
			"position": Vector3(-0.04, 0, 0),
			"rotation": Vector3(0, 0, 0),
		},
		1: {
			"position": Vector3(0, 0, 0.025),
			"rotation": Vector3(0, 0, 0),
		},
		2: {
			"position": Vector3(0.04, 0, 0),
			"rotation": Vector3(0, 0, 0),
		}
	}
}

func _ready():
	var pickup_stream = load("res://sfx/pickup.mp3")
	var swallow_stream = load("res://sfx/swallow.mp3")
		
	pickup_sfx.stream = pickup_stream
	swallow_sfx.stream = swallow_stream

func rearrange_items():
	var current_layout = layout_transforms[held_items.size()]
	
	for i in range(held_items.size()):
		var item = held_items[i]["mesh_instance"]
		var item_type = held_items[i]["item_type"]
		var transform = current_layout[i]
		
		item.position = transform["position"] + item_type.position_offset
		item.rotation = transform["rotation"] + item_type.rotation_offset
		item.scale = item_type.held_scale

func pickup_item(item_mesh, should_destroy_original, item_type: ItemType):
	if held_items.size() < inventory_limit:
		hands.visible = true
		var new_item = MeshInstance3D.new()
		new_item.mesh = item_mesh
		
		# Store both the mesh instance and the vegetable type
		var item_data = {
			"mesh_instance": new_item,
			"item_type": item_type
		}

		held_items.append(item_data)
		current_item = item_data
		
		item_placement.add_child(new_item)
		rearrange_items()
		pickup_sfx.play()
		
		print("Picked up: ", item_type.display_name)
		print_inventory_status()
		return should_destroy_original
	return false

func drop_item():
	if current_item and held_items.size() > 0:
		current_item["mesh_instance"].queue_free()
		held_items.erase(current_item)
		
		if held_items.size() > 0:
			current_item = held_items[-1]
			current_item["mesh_instance"].visible = true
			rearrange_items()
		else:
			current_item = null
			hands.visible = false
			
		swallow_sfx.play()
		print_inventory_status()
		
func get_total_points() -> int:
	var total = 0
	for item in held_items:
		total += item["item_type"].points
	return total

func print_inventory_status():
	print("\n=== Inventory Status ===")
	print("Total Points: ", get_total_points())
	print("Items held: ", held_items.size(), "/", inventory_limit)
	for i in range(held_items.size()):
		var item = held_items[i]["item_type"]
		print(str(i + 1) + ". " + item.display_name + " (" + str(item.points) + " points)")
	print("=====================\n")
