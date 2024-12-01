extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_start_game() -> void:
	animation_player.current_animation = "scene"
	animation_player.play()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://scenes/ruff_map_layout.tscn")
