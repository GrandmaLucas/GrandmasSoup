extends Node3D

@onready var item_placement: Node3D = $ItemPlacement
@export var inventory_limit = 3
var held_items = []
var current_item = null

var layout_transforms = {
	1: {  # One item
		0: {
			"position": Vector3(0, 0, 0),
			"rotation": Vector3(0, randf_range(0, 90), 0)
		}
	},
	2: {  # Two items
		0: {
			"position": Vector3(-0.025, 0, 0),
			"rotation": Vector3(0, randf_range(0, 90), 0)
		},
		1: {
			"position": Vector3(0.025, 0, 0),
			"rotation": Vector3(0, randf_range(0, 90), 0)
		}
	},
	3: {  # Three items in triangle formation
		0: {
			"position": Vector3(0, 0, 0.025),
			"rotation": Vector3(0, randf_range(0, 90), 0)
		},
		1: {
			"position": Vector3(-0.04, 0, 0),
			"rotation": Vector3(0, randf_range(0, 90), 0)
		},
		2: {
			"position": Vector3(0.04, 0, 0),
			"rotation": Vector3(0, randf_range(0, 90), 0)
		}
	}
}

func _ready():
	if !item_placement:
		push_error("ItemPlacement node not found in Inventory!")
		return

func rearrange_items():
	# Get the current layout based on number of items
	var current_layout = layout_transforms[held_items.size()]
	
	# Reposition all items based on current layout
	for i in range(held_items.size()):
		var item = held_items[i]
		var transform = current_layout[i]
		item.position = transform["position"]
		item.rotation = transform["rotation"]
		item.scale = Vector3(0.3, 0.3, 0.3)

func pickup_item(item_mesh, should_destroy_original):
	if held_items.size() < inventory_limit:
		var new_item = MeshInstance3D.new()
		new_item.mesh = item_mesh
		
		held_items.append(new_item)
		current_item = new_item
		
		# Add to the ItemPlacement node
		item_placement.add_child(new_item)
		
		# Rearrange all items based on new inventory state
		rearrange_items()
		
		return should_destroy_original
	return false

func drop_item():
	if current_item and held_items.size() > 0:
		current_item.queue_free()
		held_items.erase(current_item)
		
		if held_items.size() > 0:
			current_item = held_items[-1]
			current_item.visible = true
			# Rearrange remaining items
			rearrange_items()
		else:
			current_item = null
