extends Control

@onready var page_content: RichTextLabel = $NotebookContainer/VBoxContainer/PageContent
@onready var page_number: Label = $NotebookContainer/VBoxContainer/PageNumber
@onready var prev_button: Button = $NotebookContainer/VBoxContainer/ButtonContainer/PrevButton
@onready var next_button: Button = $NotebookContainer/VBoxContainer/ButtonContainer/NextButton
@onready var notebook_container: PanelContainer = $NotebookContainer

@export var cook: NodePath
@export var player: CharacterBody3D
@export var scroll_speed: float = 25.0  # Adjust this value to change scroll speed

var current_page: int = 0
var attempts: Array = []

class RecipeAttempt:
	var attempt_number: int
	var items_collected: Dictionary
	var total_items: int
	var accuracy: float
	var feedback: String
	
	func _init(results: Dictionary, collected_items: Array, number: int):
		attempt_number = number
		
		# Count collected items
		items_collected = {}
		for item in collected_items:
			var item_name = item["item_type"].display_name
			items_collected[item_name] = items_collected.get(item_name, 0) + 1
		
		total_items = results.get("total_submitted", 0)
		accuracy = results.get("accuracy_percentage", 0.0)
		feedback = results.get("feedback", "")

	func format_page() -> String:
		var text = "[center][font=res://fonts/kalam.ttf][b]Attempt #%d[/b][/font][/center]\n\n" % attempt_number
		
		text += "[center][font=res://fonts/kalam.ttf][b]===== Ingredients =====[/b][/font][/center]\n"
		for item_name in items_collected:
			text += "[center]%s: %d[/center]\n" % [item_name, items_collected[item_name]]
		
		text += "\n[center][font=res://fonts/kalam.ttf][b]====== Statistics ======[/b][/font][/center]\n"
		text += "[center]Total items: %d[/center]\n" % total_items
		text += "[center]Accuracy: %.1f%%[/center]\n" % accuracy
		
		text += "\n[center][font=res://fonts/kalam.ttf][b]==== Taste Feedback ====[/b][/font][/center]\n"
		var formatted_feedback = feedback.replace("\n", "\n• ")
		text += "[center]%s[/center]" % formatted_feedback
		
		return text

func _ready():
	# Load resources and apply styling
	var handwriting_font = load("res://fonts/kalam.ttf")
	
	# Get cook node reference and connect signals
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
	page_content.add_theme_font_override("bold_font", handwriting_font)
	page_content.add_theme_font_size_override("normal_font_size", 20)
	page_content.add_theme_font_size_override("bold_font_size", 24)
	page_content.add_theme_color_override("default_color", Color("#2B1B17"))
	
	# Style the notebook container
	notebook_container.add_theme_stylebox_override("panel", get_paper_style())
	
	# Style the buttons
	var button_style = get_button_style()
	prev_button.add_theme_stylebox_override("normal", button_style)
	next_button.add_theme_stylebox_override("normal", button_style)
	prev_button.add_theme_font_override("font", handwriting_font)
	next_button.add_theme_font_override("font", handwriting_font)
	prev_button.add_theme_font_size_override("font_size", 18)
	next_button.add_theme_font_size_override("font_size", 18)
	
	# Connect button signals
	prev_button.pressed.connect(_on_prev_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	
	# Enable mouse filter for the RichTextLabel to receive input
	page_content.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Make sure scroll is enabled
	page_content.scroll_following = false
	page_content.scroll_active = true
	
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
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				# Scroll up
				page_content.get_v_scroll_bar().value -= scroll_speed
				get_viewport().set_input_as_handled()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				# Scroll down
				page_content.get_v_scroll_bar().value += scroll_speed
				get_viewport().set_input_as_handled()
		elif event.is_action_pressed("previous_page"):
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
		var attempt = RecipeAttempt.new(results, cook_node.collected_items, attempts.size() + 1)
		attempts.append(attempt)
		current_page = attempts.size() - 1
		update_page_content()
		update_page_buttons()
	else:
		push_error("Notebook: Cook node not found! Check editor reference")

func get_button_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#8B4513")  # Brown color for buttons
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color("#2B1B17")
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style

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
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	return style

func update_page_content():
	print("Updating page content")
	if attempts.size() > 0:
		var attempt = attempts[current_page]
		page_content.text = attempt.format_page()
		page_number.text = "Page %d/%d" % [current_page + 1, attempts.size()]
		# Reset scroll position when changing pages
		page_content.get_v_scroll_bar().value = 0
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
	prev_button.visible = current_page > 0
	next_button.visible = current_page < attempts.size() - 1

func _on_prev_button_pressed():
	previous_page()

func _on_next_button_pressed():
	next_page()

func set_player(p_player: Node3D):
	player = p_player
