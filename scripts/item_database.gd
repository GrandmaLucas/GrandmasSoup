extends Node

var items = {}

func _ready():
	create_item_types()

func create_item_types():
	# Create tomato type
	var tomato = ItemType.new()
	tomato.id = "tomato"
	tomato.display_name = "Tomato"
	tomato.held_scale = Vector3(0.3, 0.3, 0.3)
	tomato.rotation_offset = Vector3(0, 0, 0)
	tomato.position_offset = Vector3(0, 0, 0)
	
	# Create carrot type
	var carrot = ItemType.new()
	carrot.id = "carrot"
	carrot.display_name = "Carrot"
	carrot.held_scale = Vector3(0.15, 0.15, 0.15)
	carrot.rotation_offset = Vector3(-47.5, -7.5, -10)
	carrot.position_offset = Vector3(0, -0.015, 0.0125)
	
	# Create onion type
	var onion = ItemType.new()
	onion.id = "onion"
	onion.display_name = "Onion"
	onion.held_scale = Vector3(0.2, 0.2, 0.2)
	onion.rotation_offset = Vector3(0, 0, 0)
	onion.position_offset = Vector3(0, 0, 0)
	
	# Create carrot type
	var pepper = ItemType.new()
	pepper.id = "pepper"
	pepper.display_name = "Pepper"
	pepper.held_scale = Vector3(0.15, 0.15, 0.15)
	pepper.rotation_offset = Vector3(-231.2, -157.5, 22.5)
	pepper.position_offset = Vector3(0, 0.005, 0.008)
	
	# Create mushroom type
	var mushroom = ItemType.new()
	mushroom.id = "mushroom"
	mushroom.display_name = "Mushroom"
	mushroom.held_scale = Vector3(0.25, 0.25, 0.25)
	mushroom.rotation_offset = Vector3(-231.2, -157.5, 22.5)
	mushroom.position_offset = Vector3(-0.015, 0.02, 0.03)
	
	# Create onion type
	var potato = ItemType.new()
	potato.id = "potato"
	potato.display_name = "Potato"
	potato.held_scale = Vector3(0.28, 0.28, 0.28)
	potato.rotation_offset = Vector3(90, 0, 75)
	potato.position_offset = Vector3(-0.01, 0.02, 0.005)
	
	var meat = ItemType.new()
	meat.id = "meat"
	meat.display_name = "Meat"
	meat.held_scale = Vector3(0.12, 0.12, 0.12)
	meat.rotation_offset = Vector3(1, 0, 0)
	meat.position_offset = Vector3(0, 0.02, 0)
	
	var broth = ItemType.new()
	broth.id = "broth"
	broth.display_name = "Broth"
	broth.held_scale = Vector3(0.14, 0.14, 0.14)
	broth.rotation_offset = Vector3(0, 0, 0)
	broth.position_offset = Vector3(0, 0, 0)
	
	# Store in dictionary
	items["tomato"] = tomato
	items["carrot"] = carrot
	items["onion"] = onion
	items["pepper"] = pepper
	items["mushroom"] = mushroom
	items["potato"] = potato
	items["meat"] = meat
	items["broth"] = broth

func get_item_type(id: String) -> ItemType:
	return items.get(id)
