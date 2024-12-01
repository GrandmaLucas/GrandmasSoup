extends Control

signal start_game

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.visible = true

	
func _on_play_pressed() -> void:
	self.visible = false
	emit_signal("start_game")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_quit_pressed() -> void:
	get_tree().quit()

