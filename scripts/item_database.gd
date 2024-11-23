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
	
	# Store in dictionary
	items["tomato"] = tomato
	items["carrot"] = carrot
	items["onion"] = onion
	items["pepper"] = pepper
	items["mushroom"] = mushroom

func get_item_type(id: String) -> ItemType:
	return items.get(id)
