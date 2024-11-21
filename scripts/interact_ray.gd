extends RayCast3D

@onready var prompt = $Prompt
@onready var player = find_player()

var previous_interactable = null
var current_interactable = null

func find_player():
	var current_node = self
	while current_node != null:
		if current_node is CharacterBody3D:
			return current_node
		current_node = current_node.get_parent()
	return null

func _physics_process(_delta):
	prompt.text = ""
	current_interactable = null
	
	if is_colliding():
		var collider = get_collider()
		# Check for interactable objects
		if collider.get_parent() is Interactable:
			current_interactable = collider.get_parent()
		elif collider is Interactable:
			current_interactable = collider

	# Handle focus change
	if previous_interactable != current_interactable:
		if previous_interactable and previous_interactable.has_method("unfocus"):
			previous_interactable.unfocus()
		if current_interactable and current_interactable.has_method("focus"):
			current_interactable.focus(player)
		previous_interactable = current_interactable

	if current_interactable:
		prompt.text = current_interactable.get_prompt()
		if Input.is_action_just_pressed("interact") and player:
			current_interactable.interact(player)
