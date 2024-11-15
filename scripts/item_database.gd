extends Node

var items = {}

func _ready():
	create_item_types()

func create_item_types():
	# Create tomato type
	var tomato = ItemType.new()
	tomato.id = "tomato"
	tomato.display_name = "Tomato"
	tomato.points = 10
	tomato.held_scale = Vector3(0.3, 0.3, 0.3)
	tomato.rotation_offset = Vector3(0, 0, 0)
	tomato.position_offset = Vector3(0, 0, 0)
	
	# Create carrot type
	var carrot = ItemType.new()
	carrot.id = "carrot"
	carrot.display_name = "Carrot"
	carrot.points = 15
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
	
	# Store in dictionary
	items["tomato"] = tomato
	items["carrot"] = carrot
	items["onion"] = onion

func get_item_type(id: String) -> ItemType:
	return items.get(id)
