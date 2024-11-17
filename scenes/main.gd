extends Node

func _ready():
	var notebook = Control.new()
	notebook.set_script(load("res://scripts/notebook.gd"))
	add_child(notebook)
	
	# Set the cook property using the node path
	notebook.set("cook", $Cook.get_path())
