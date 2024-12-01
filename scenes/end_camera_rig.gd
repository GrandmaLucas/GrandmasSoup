extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.current_animation = "end"
	animation_player.play()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().quit()
