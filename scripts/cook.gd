# cook.gd
extends Interactable
class_name Cook

@export var player: Node3D
@onready var label_3d: Label3D = $Label3D
@onready var recipe = Recipe.new()
@onready var inventory: Inventory = $"../../../../CharacterBody3D/Head/Camera3D/Inventory"
@onready var submit_progress_bar: ProgressBar = $"../../../../CharacterBody3D/Head/Camera3D/InteractRay/Prompt/SubmitProgressBar"
@onready var soup_level = $StaticBody3D/Soup/stew_bowl
@onready var grandpa: Node3D = $"../../../Grandpa"

var current_count: int = 0
var collected_items = []
var submit_hold_time: float = -0.3
const SUBMIT_TIME_REQUIRED: float = 1.5  # Seconds to hold E

signal recipe_submitted(results)
signal items_received(items_count)

func _ready():
	if not player:
		print("Player not assigned in editor!")
		return

	# Get the inventory node from the player
	if not inventory:
		print("Inventory not found!")
	else:
		print("Inventory successfully referenced.")

	# Initialize ProgressBar
	submit_progress_bar.visible = false
	submit_progress_bar.value = 0
	submit_progress_bar.min_value = 0
	submit_progress_bar.max_value = 1

	update_prompt()
	# Set up the 3D label
	label_3d.text = "0/%d" % recipe.max_items
	label_3d.font_size = 300
	label_3d.pixel_size = 0.0005
	label_3d.modulate = Color.WHITE
	label_3d.outline_size = 75
	label_3d.outline_modulate = Color.BLACK
	update_display()
	
	recipe.perfect_recipe.connect(_on_perfect_recipe)
	
func _on_perfect_recipe():
	grandpa.perfect_recipe()

func focus(_player):
	is_focused = true

func unfocus():
	is_focused = false
	submit_hold_time = -0.3
	submit_progress_bar.visible = false

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

	if is_focused:
		if collected_items.size() > 0:
			if inventory.held_items.size() == 0:
				submit_progress_bar.visible = true
			else:
				submit_progress_bar.visible = false
		# Handle hold-to-submit
		if Input.is_action_pressed("interact") and is_player_near():
			if inventory and inventory.held_items.size() == 0 and collected_items.size() > 0:
				# Only show progress bar if cook has items AND player's hands are empty
				submit_hold_time += delta
				var progress = submit_hold_time / SUBMIT_TIME_REQUIRED
				submit_progress_bar.value = progress
				submit_progress_bar.visible = true

				if submit_hold_time >= SUBMIT_TIME_REQUIRED:
					submit_hold_time = -0.3
					submit_progress_bar.visible = false
					var validation_results = validate_collection()
					emit_signal("recipe_submitted", validation_results)
					clear_collection()
					update_prompt()
					update_soup()
			else:
				submit_hold_time = -0.3
				submit_progress_bar.value = 0
		else:
			submit_hold_time = -0.3
			submit_progress_bar.value = 0
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
	update_soup()
	emit_signal("items_received", results.items_accepted)

	return results

func validate_collection() -> Dictionary:
	var results = recipe.validate_items(collected_items)
	results["total_submitted"] = collected_items.size()
	results["wrong_items"] = results.get("wrong_items", 0)
	
	# Add feedback about the total number of items
	if collected_items.size() < recipe.required_total:
		results["item_count_feedback"] = "Needs more ingredients"
	elif collected_items.size() > recipe.required_total:
		results["item_count_feedback"] = "Too many ingredients"
	else:
		results["item_count_feedback"] = "Perfect amount of ingredients!"
	
	return results

func clear_collection():
	collected_items.clear()
	current_count = 0
	update_display()

func update_display():
	label_3d.text = "%d/%d" % [current_count, recipe.max_items]

func update_prompt():
	if inventory and inventory.held_items.size() > 0:
		if collected_items.size() == 20:
			prompt_message = "Full\n"
		else:
			if inventory.held_items.size() == 1:
				prompt_message = "Give ingredient\n[E]"
			elif collected_items.size() + inventory.held_items.size() > 20:
				prompt_message = "Too many ingredients in hands\n"
			else:
				prompt_message = "Give ingredients\n[E]"
	elif collected_items.size() == 0:
		prompt_message = "Needs ingredients\n"
	elif collected_items.size() == 20:
		prompt_message = "Full, hold to submit recipe\n[E]\n"
	else:
		prompt_message = "Hold to submit recipe\n[E]"

func get_prompt():
	update_prompt()
	return prompt_message

func is_player_near() -> bool:
	return global_transform.origin.distance_to(player.global_transform.origin) < 6

func update_soup():
	soup_level.rotate_y(randi_range(-360, 360))
	var audio_player = $AudioStreamPlayer3D
	if collected_items.size() == 0:
		soup_level.visible = false
		audio_player.volume_db = -80
	elif collected_items.size() >= 1 and collected_items.size() <= 4:
		audio_player.volume_db = 6
		soup_level.position.y = -0.3
		soup_level.visible = true
	elif collected_items.size() >= 5 and collected_items.size() <= 8:
		soup_level.position.y = -0.275
	elif collected_items.size() >= 9 and collected_items.size() <= 12:
		soup_level.position.y = -0.25
	elif collected_items.size() >= 13 and collected_items.size() <= 15:
		soup_level.position.y = -0.225
	elif collected_items.size() >= 16 and collected_items.size() <= 17:
		soup_level.position.y = -0.20
	elif collected_items.size() >= 18 and collected_items.size() <= 19:
		soup_level.position.y = -0.175
	elif collected_items.size() >= 20:
		soup_level.position.y = -0.155
