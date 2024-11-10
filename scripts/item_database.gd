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
	
	# Create carrot type
	var carrot = ItemType.new()
	carrot.id = "carrot"
	carrot.display_name = "Carrot"
	carrot.points = 15
	
	# Store in dictionary
	items["tomato"] = tomato
	items["carrot"] = carrot

func get_item_type(id: String) -> ItemType:
	return items.get(id)
