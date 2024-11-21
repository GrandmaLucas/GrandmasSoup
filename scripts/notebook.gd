# Scene Tree Structure (.tscn):
# Notebook (Control)
# ├── NotebookContainer (PanelContainer)
#     └── VBoxContainer
#         ├── PageContent (RichTextLabel)
#         ├── PageNumber (Label)
#         └── ButtonContainer (HBoxContainer)
#             ├── PrevButton (Button)
#             ├── Spacer (Control)
#             └── NextButton (Button)

extends Control

@onready var page_content: RichTextLabel = $NotebookContainer/VBoxContainer/PageContent
@onready var page_number: Label = $NotebookContainer/VBoxContainer/PageNumber
@onready var prev_button: Button = $NotebookContainer/VBoxContainer/ButtonContainer/PrevButton
@onready var next_button: Button = $NotebookContainer/VBoxContainer/ButtonContainer/NextButton
@onready var notebook_container: PanelContainer = $NotebookContainer

@export var cook: NodePath  # Assign this in editor
@export var player: CharacterBody3D  # Assign this in editor

var current_page: int = 0
var attempts: Array = []

class RecipeAttempt:
	var timestamp: String
	var items_collected: Dictionary
	var total_items: int
	var accuracy: float
	var wrong_items: int
	var feedback: String
	
	func _init(results: Dictionary, collected_items: Array):
		timestamp = Time.get_datetime_string_from_system()
		
		# Count collected items
		items_collected = {}
		for item in collected_items:
			var item_name = item["item_type"].display_name
			items_collected[item_name] = items_collected.get(item_name, 0) + 1
		
		total_items = results.get("total_submitted", 0)
		accuracy = results.get("accuracy_percentage", 0.0)
		wrong_items = results.get("wrong_items", 0)
		feedback = results.get("feedback", "")

	func format_page() -> String:
		var text = "[center][b]Attempt from %s[/b][/center]\n\n" % timestamp
		
		text += "[b]=== Ingredients ===[/b]\n"
		for item_name in items_collected:
			text += "%s: %d\n" % [item_name, items_collected[item_name]]
		
		text += "\n[b]=== Statistics ===[/b]\n"
		text += "Total items: %d\n" % total_items
		text += "Accuracy: %.1f%%\n" % accuracy
		text += "Wrong items: %d\n\n" % wrong_items
		
		text += "[b]=== Cook's Feedback ===[/b]\n"
		text += feedback.replace("\n", "\n• ")
		
		return text

func _ready():
	# Load resources and apply styling
	var handwriting_font = load("res://fonts/kalam.ttf")
	
	# Get cook node reference
	var cook_node = get_node_or_null(cook)
	if cook_node:
		print("Found cook node: ", cook_node.name)
		if not cook_node.is_connected("recipe_submitted", _on_recipe_submitted):
			cook_node.connect("recipe_submitted", _on_recipe_submitted)
			print("Connected recipe_submitted signal")
	else:
		push_error("Notebook: Cook node not found! Check editor reference")

	# Apply styling to existing nodes
	page_content.add_theme_font_override("normal_font", handwriting_font)
	page_content.add_theme_font_size_override("normal_font_size", 20)
	page_content.add_theme_color_override("default_color", Color("#2B1B17"))
	notebook_container.add_theme_stylebox_override("panel", get_paper_style())
	
	# Connect button signals
	prev_button.pressed.connect(_on_prev_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	
	# Initialize UI
	update_page_buttons()
	
	# Hide notebook initially
	hide()
	
	# Connect input handling
	set_process_input(true)

# Rest of the functions remain the same as in your original script
func _input(event: InputEvent):
	if event.is_action_pressed("toggle_notebook"):
		toggle_notebook()
	
	if visible:
		if event.is_action_pressed("previous_page"):
			previous_page()
		elif event.is_action_pressed("next_page"):
			next_page()

func toggle_notebook():
	visible = !visible
	if visible:
		if player:
			player.set_physics_process(false)
		update_page_content()
	else:
		if player:
			player.set_physics_process(true)

func _on_recipe_submitted(results: Dictionary):
	print("Recipe submitted signal received")
	var cook_node = get_node_or_null(cook)
	if cook_node:
		var attempt = RecipeAttempt.new(results, cook_node.collected_items)
		attempts.append(attempt)
		current_page = attempts.size() - 1
		update_page_content()
		update_page_buttons()
	else:
		push_error("Notebook: Cook node not found! Check editor reference")

func update_page_content():
	print("Updating page content")
	if attempts.size() > 0:
		var attempt = attempts[current_page]
		page_content.text = attempt.format_page()
		page_number.text = "Page %d/%d" % [current_page + 1, attempts.size()]
	else:
		page_content.text = "[center]No attempts recorded yet.[/center]"
		page_number.text = "Page 1/1"

func next_page():
	if current_page < attempts.size() - 1:
		current_page += 1
		update_page_content()
		update_page_buttons()

func previous_page():
	if current_page > 0:
		current_page -= 1
		update_page_content()
		update_page_buttons()

func update_page_buttons():
	prev_button.disabled = current_page <= 0
	next_button.disabled = current_page >= attempts.size() - 1

func _on_prev_button_pressed():
	previous_page()

func _on_next_button_pressed():
	next_page()

func set_player(p_player: Node3D):
	player = p_player

func get_paper_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#FFFDF3")
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color("#D3D3D3")
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5
	style.shadow_size = 4
	style.shadow_color = Color("#00000033")
	return style
