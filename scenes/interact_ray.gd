extends RayCast3D

@onready var prompt = $Prompt
@onready var player = find_player()

func find_player():
	var current_node = self
	while current_node != null:
		if current_node is CharacterBody3D:
			return current_node
		current_node = current_node.get_parent()
	return null

func _physics_process(_delta):
	prompt.text = ""
	
	if is_colliding():
		var collider = get_collider()
		var interactable
		
		# If we hit a StaticBody3D or Area3D, check if its parent is Interactable
		if collider is StaticBody3D or collider is Area3D:
			if collider.get_parent() is Interactable:
				interactable = collider.get_parent()
		# If we directly hit an Interactable somehow
		elif collider is Interactable:
			interactable = collider
			
		if interactable:
			prompt.text = interactable.get_prompt()
			
			if Input.is_action_just_pressed("interact") and player:
				interactable.interact(player)
