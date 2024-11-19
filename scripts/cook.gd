# cook.gd
extends Node3D
class_name Cook

@export var player: Node3D
@onready var label_3d: Label3D = $Label3D
@export var prompt_message = "Give Ingredients"
@onready var inventory: Node3D = $"../CharacterBody3D/Head/Camera3D/Inventory"
@onready var recipe = Recipe.new()

var current_count: int = 0
var max_items: int:
	get:
		return recipe.max_items if recipe else 15

signal recipe_submitted(results)
signal item_received(item_type)
signal items_received(items_count)

func _ready():
	if !recipe:
		recipe = Recipe.new()
	
	# Set up the 3D label
	label_3d.text = "0/15"
	label_3d.font_size = 300
	label_3d.pixel_size = 0.0005
	label_3d.modulate = Color.WHITE
	label_3d.outline_size = 75
	label_3d.outline_modulate = Color.BLACK
	
	update_display()

func interact(_player):
	inventory.give_current_item()

var collected_items = []

func get_prompt():
	return prompt_message + "\n[E]"

func receive_items(items_array: Array) -> Dictionary:
	var results = {
		"success": false,
		"items_accepted": 0,
		"error": ""
	}
	
	var potential_total = collected_items.size() + items_array.size()
	
	# Strict check for exact limit
	if potential_total > recipe.max_items:
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
	current_count += results.items_accepted
	update_display()
	
	# Emit signal with count of received items
	emit_signal("items_received", results.items_accepted)
	
	# Check if we've exactly reached max items
	if collected_items.size() == max_items:
		var validation_results = validate_collection()
		emit_signal("recipe_submitted", validation_results)
		clear_collection()
	
	return results

func validate_collection() -> Dictionary:
	var results = recipe.validate_items(collected_items)
	
	# Add these keys to ensure the Notebook can use them
	results["total_submitted"] = collected_items.size()
	results["wrong_items"] = results.get("wrong_items", 0)
	
	print("\n=== Recipe Validation ===")
	print("Total items collected: %d" % collected_items.size())
	print("Accuracy: %.1f%%" % results.accuracy_percentage)
	print("Wrong items: %1f%%" % results.wrong_items)
	print("\nFeedback:")
	print(results.feedback)
	
	if results.is_perfect:
		print("\nPerfect match! Recipe complete!")
	print("=====================\n")
	
	return results

func update_display():
	label_3d.text = str(current_count) + "/" + str(recipe.max_items)

func clear_collection():
	collected_items.clear()
	current_count = 0
	update_display()
	print("Cook collection cleared!")

func _process(_delta):
	# Ensure the NPC and label always face the player
	if player:
		label_3d.look_at(player.global_transform.origin, Vector3(0, 1, 0))
		label_3d.rotation.y += PI
		label_3d.rotation.x = 0
		label_3d.rotation.z = 0
