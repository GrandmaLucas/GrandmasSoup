extends Control

@onready var main_menu: ColorRect = $MainMenu
@onready var settings_menu: ColorRect = $SettingsMenu
@onready var volume: HSlider = $SettingsMenu/VBoxContainer/HBoxContainer2/VBoxContainer/HSlider
@onready var player: CharacterBody3D = $"../CharacterBody3D"
@onready var sensitivity: HSlider = $SettingsMenu/VBoxContainer/HBoxContainer3/VBoxContainer/HSlider
@onready var button_click: AudioStreamPlayer = $"../CharacterBody3D/ButtonClick"

var is_paused = false:
	set = set_paused
	
func _ready():
	volume.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	sensitivity.value = (player.MOUSE_SENSITIVITY)*3

	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		is_paused = !is_paused
		if is_paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			main_menu.visible = true
			settings_menu.visible = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			main_menu.visible = false
			settings_menu.visible = false
	
func set_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused

func _on_resume_pressed() -> void:
	is_paused = false
	button_click.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_settings_button_pressed() -> void:
	main_menu.visible = false
	settings_menu.visible = true
	button_click.play()

func _on_quit_button_pressed() -> void:
	button_click.play()
	get_tree().quit()
	
#Settings
func _on_return_pressed() -> void:
	button_click.play()
	main_menu.visible = true
	settings_menu.visible = false

func _on_sensitivity_changed(value: float) -> void:
	player.MOUSE_SENSITIVITY = value/3

func _on_display_mode_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		1:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
