extends Control

var page_content: RichTextLabel
var page_number: Label
var prev_button: Button
var next_button: Button
var notebook_container: PanelContainer
@export var cook: NodePath
@onready var cook_node: Cook = get_node(cook)

var current_page: int = 0
var attempts: Array = []

class RecipeAttempt:
	var timestamp: String
	var items_collected: Dictionary
	var total_items: int
	var accuracy: float
	var correct_items: int
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
		correct_items = results.get("correct_items", 0)
		wrong_items = results.get("wrong_items", 0)
		feedback = results.get("feedback", "")
	
	func format_page() -> String:
		var text = "[center][b]Attempt from %s[/b][/center]\n\n" % timestamp
		
		text += "[b]=== Ingredients Used ===[/b]\n"
		for item_name in items_collected:
			text += "%s: %d\n" % [item_name, items_collected[item_name]]
		
		text += "\n[b]=== Cook's Feedback ===[/b]\n"
		text += "Total items: %d\n" % total_items
		text += "Accuracy: %.1f%%\n" % accuracy
		text += "Correct items: %d\n" % correct_items
		text += "Wrong items: %d\n\n" % wrong_items
		
		text += "[b]Notes:[/b]\n"
		text += feedback.replace("\n", "\n• ")
		
		return text

func _ready():
	# Set up the control to take full screen
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	# Create notebook container
	notebook_container = PanelContainer.new()
	notebook_container.set_anchors_preset(Control.PRESET_CENTER)
	notebook_container.custom_minimum_size = Vector2(400, 500)
	add_child(notebook_container)
	
	# Create vertical container for content
	var v_box = VBoxContainer.new()
	notebook_container.add_child(v_box)
	
	# Create page content
	page_content = RichTextLabel.new()
	page_content.bbcode_enabled = true
	page_content.fit_content = true
	page_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_content.custom_minimum_size = Vector2(0, 400)
	v_box.add_child(page_content)
	
	# Create page number label
	page_number = Label.new()
	page_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_number.text = "Page 0/0"
	v_box.add_child(page_number)
	
	# Create button container
	var button_container = HBoxContainer.new()
	button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v_box.add_child(button_container)
	
	# Create navigation buttons
	prev_button = Button.new()
	prev_button.text = "< Previous"
	prev_button.pressed.connect(_on_prev_button_pressed)
	button_container.add_child(prev_button)
	
	# Add spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_container.add_child(spacer)
	
	next_button = Button.new()
	next_button.text = "Next >"
	next_button.pressed.connect(_on_next_button_pressed)
	button_container.add_child(next_button)
	
	# Initialize UI
	update_page_buttons()
	
	# Connect to cook's signals
	if cook_node:
		cook_node.connect("recipe_submitted", _on_recipe_submitted)
	
	# Hide notebook initially
	hide()
	
	# Connect input handling
	set_process_input(true)

func _input(event: InputEvent):
	if event.is_action_pressed("toggle_notebook"):  # Define this in Project Settings > Input Map
		toggle_notebook()
	
	if visible:
		if event.is_action_pressed("previous_page"):  # Define this in Project Settings
			previous_page()
		elif event.is_action_pressed("next_page"):  # Define this in Project Settings
			next_page()

func toggle_notebook():
	visible = !visible
	if visible:
		# Update content when showing notebook
		update_page_content()

func _on_recipe_submitted(results: Dictionary):
	var attempt = RecipeAttempt.new(results, cook_node.collected_items)
	attempts.push_front(attempt)  # Add new attempts at the start
	current_page = 0
	update_page_content()
	update_page_buttons()

func update_page_content():
	if attempts.size() > 0:
		var attempt = attempts[current_page]
		page_content.text = attempt.format_page()
		page_number.text = "Page %d/%d" % [current_page + 1, attempts.size()]
	else:
		page_content.text = "[center]No attempts recorded yet.[/center]"
		page_number.text = "Page 0/0"

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
