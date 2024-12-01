extends Node3D
@onready var bell_sfx: AudioStreamPlayer3D = $BellSfx
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var grandpa_sfx: AudioStreamPlayer3D = $GrandpaSfx
@onready var arms: MeshInstance3D = $Arms
@onready var hands: MeshInstance3D = $Hands
@onready var area_3d: Area3D = $"../../Area3D"

func _ready() -> void:
	animation_player.current_animation = "grandpa"
	animation_player.play()
	bell_sfx.autoplay = true
	bell_sfx.playing = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	bell_sfx.queue_free()
	animation_player.queue_free()
	grandpa_voice()
	area_3d.queue_free()
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play()

func grandpa_voice():
	grandpa_sfx.play()
