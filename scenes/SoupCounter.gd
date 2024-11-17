extends Node3D

@export var player: Node3D
@onready var label_3d: Label3D = $Label3D
@export var cook: NodePath
@onready var cook_node: Cook = get_node(cook)
var current_count: int = 0
var max_items: int = 15

func _ready():
	# Set up the 3D label
	label_3d.text = "0/15"
	label_3d.font_size = 300
	label_3d.pixel_size = 0.0005
	label_3d.modulate = Color.WHITE
	label_3d.outline_size = 75
	label_3d.outline_modulate = Color.BLACK
	
	# Connect to the cook's signals
	if cook_node:
		cook_node.connect("items_received", _on_items_received)
		cook_node.connect("recipe_submitted", _on_recipe_submitted)
		# Get max_items using the getter
		max_items = cook_node.max_items
		update_display()
	else:
		push_error("SoupCounter: Cook node not found!")

func _on_items_received(items_count: int):
	current_count += items_count
	update_display()

func _on_recipe_submitted(_results: Dictionary):
	update_display()

func update_display():
	# Update the counter text
	label_3d.text = str(current_count) + "/" + str(max_items)

func reset():
	current_count = 0
	update_display()
	
func _process(_delta):
	# Ensure the NPC always faces the player
	if player:
		label_3d.look_at(player.global_transform.origin, Vector3(0, 1, 0))
		label_3d.rotation.y += PI  # Rotate 180 degrees around Y-axis
		label_3d.rotation.x = 0
		label_3d.rotation.z = 0
