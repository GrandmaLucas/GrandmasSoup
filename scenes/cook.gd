extends Node3D
class_name Cook

@export var player: Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var prompt_message = "Give Ingredients"
@onready var inventory: Node3D = $"../CharacterBody3D/Head/Camera3D/Inventory"

signal recipe_submitted(results)
signal item_received(item_type)

func interact(player):
	inventory.give_current_item()

@onready var recipe = Recipe.new()
var collected_items = []

func get_prompt():
	return prompt_message + "\n[E]"

func receive_items(items_array: Array) -> Dictionary:
	var results = {
		"success": false,
		"items_accepted": 0,
		"error": ""
	}
	
	# Check if adding these items would exceed the limit
	if collected_items.size() + items_array.size() > recipe.max_items:
		results.error = "Too many items! Only %d more items can be accepted." % (recipe.max_items - collected_items.size())
		return results
	
	# Add all items
	for item_data in items_array:
		var clean_item_data = {
			"item_type": item_data["item_type"]
		}
		collected_items.append(clean_item_data)
		results.items_accepted += 1
	
	results.success = true
	
	print("\n=== Collector Status ===")
	print_collection_status()
	print("=====================\n")
	
	# Emit signal with count of received items
	emit_signal("items_received", results.items_accepted)
	
	# Check if we've reached max items
	if collected_items.size() == recipe.max_items:
		var validation_results = validate_collection()
		emit_signal("recipe_submitted", validation_results)
	
	return results

func validate_collection() -> Dictionary:
	var results = recipe.validate_items(collected_items)
	
	print("\n=== Recipe Validation ===")
	print("Total items colected: %d" % collected_items.size())
	print("Accuracy: %.1f%%" % results.accuracy_percentage)
	print("Correct items: %d" % results.correct_items)
	print("Wrong items: %d" % results.wrong_items)
	print("\nFeedback:")
	print(results.feedback)
	
	if results.is_perfect:
		print("\nPerfect match! Recipe complete!")
	print("=====================\n")
	
	return results

func print_collection_status():
	print("Items collected: %d/%d" % [collected_items.size(), recipe.max_items])
	var item_counts = {}
	for item in collected_items:
		var item_name = item["item_type"].display_name
		item_counts[item_name] = item_counts.get(item_name, 0) + 1
	
	for item_name in item_counts:
		print("%s: %d" % [item_name, item_counts[item_name]])

func clear_collection():
	collected_items.clear()

func _ready():
	play_idle_animation()

func _process(_delta):
	# Ensure the NPC always faces the player
	if player:
		look_at(player.global_transform.origin, Vector3(0, 1, 0))
		rotation.y += PI  # Rotate 180 degrees around Y-axis
		rotation.x = 0
		rotation.z = 0

	play_idle_animation()

func play_idle_animation():
	# Check if the idle animation is not already playing, then play it
	if animation_player and !animation_player.is_playing():
		animation_player.play("HumanArmature|Man_Idle")
