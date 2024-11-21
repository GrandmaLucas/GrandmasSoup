# cook.gd
extends Node3D
class_name Cook

@export var player: Node3D
@onready var label_3d: Label3D = $Label3D
@onready var recipe = Recipe.new()
@onready var inventory : Node3D = $"../CharacterBody3D/Head/Camera3D/Inventory"
@onready var submit_progress_bar = $"../CharacterBody3D/Head/Camera3D/InteractRay/Prompt/SubmitProgressBar"

var current_count: int = 0
var collected_items = []
var submit_hold_time: float = 0.0
const SUBMIT_TIME_REQUIRED: float = 1.5  # Seconds to hold E

var prompt_message = ""

signal recipe_submitted(results)
signal items_received(items_count)

func _ready():
	submit_progress_bar.visible = false

	update_prompt()
	# Set up the 3D label
	label_3d.text = "0/%d" % recipe.max_items
	label_3d.font_size = 300
	label_3d.pixel_size = 0.0005
	label_3d.modulate = Color.WHITE
	label_3d.outline_size = 75
	label_3d.outline_modulate = Color.BLACK
	update_display()

func interact(_player):
	if inventory and inventory.held_items.size() > 0:
		inventory.give_current_item()
		update_prompt()

func _process(delta):
	# Face player
	if player:
		label_3d.look_at(player.global_transform.origin, Vector3.UP)
		label_3d.rotation.x = 0
		label_3d.rotation.z = 0
		label_3d.rotation.y += PI

	# Handle hold-to-submit
	if Input.is_action_pressed("interact") and is_player_near():
		if inventory and inventory.held_items.size() == 0:
			submit_hold_time += delta

			# Update ProgressBar
			var progress = (submit_hold_time / SUBMIT_TIME_REQUIRED)
			submit_progress_bar.value = progress
			submit_progress_bar.visible = true

			if submit_hold_time >= SUBMIT_TIME_REQUIRED:
				submit_hold_time = -0.3
				submit_progress_bar.visible = false
				if collected_items.size() > 0:
					var validation_results = validate_collection()
					emit_signal("recipe_submitted", validation_results)
					clear_collection()
					update_prompt()
		else:
			submit_hold_time = -0.3
			submit_progress_bar.visible = false
	else:
		submit_hold_time = -0.3
		submit_progress_bar.visible = false

func receive_items(items_array: Array) -> Dictionary:
	var results = {
		"success": false,
		"items_accepted": 0,
		"error": ""
	}

	var potential_total = collected_items.size() + items_array.size()

	if potential_total > recipe.max_items:
		results.error = "Too many items! Only %d more items can be accepted." % (recipe.max_items - collected_items.size())
		return results

	# Add items
	for item_data in items_array:
		var clean_item_data = {
			"item_type": item_data["item_type"]
		}
		collected_items.append(clean_item_data)
		results.items_accepted += 1

	results.success = true
	current_count += results.items_accepted
	update_display()
	update_prompt()
	emit_signal("items_received", results.items_accepted)

	return results

func validate_collection() -> Dictionary:
	var results = recipe.validate_items(collected_items)
	results["total_submitted"] = collected_items.size()
	results["wrong_items"] = results.get("wrong_items", 0)
	return results

func clear_collection():
	collected_items.clear()
	current_count = 0
	update_display()

func update_display():
	label_3d.text = "%d/%d" % [current_count, recipe.max_items]

func update_prompt():
	if inventory and inventory.held_items.size() > 0:
		if inventory.held_items.size() == 1:
			prompt_message = "Give ingredient\n[E]"
			submit_progress_bar.visible = false
		else:
			prompt_message = "Give ingredients\n[E]"
			submit_progress_bar.visible = false
	elif collected_items.size() == 0:
		# Cook has no ingredients
		prompt_message = "Needs ingredients\n"
		submit_progress_bar.visible = false
	else:
		# Player can submit the recipe
		prompt_message = "Hold to submit recipe\n[E]"
		submit_progress_bar.visible = true

func get_prompt():
	update_prompt()
	return prompt_message

func is_player_near() -> bool:
	return global_transform.origin.distance_to(player.global_transform.origin) < 2  # Adjust as needed
