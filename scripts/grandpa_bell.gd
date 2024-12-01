extends Node3D
@onready var bell_sfx: AudioStreamPlayer3D = $BellSfx
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var grandpa_sfx: AudioStreamPlayer3D = $GrandpaSfx
@onready var arms: MeshInstance3D = $Arms
@onready var hands: MeshInstance3D = $Hands
@onready var area_3d: Area3D = $"../../Area3D"

#second time
@onready var bell_sfx_2: AudioStreamPlayer3D = $BellSfx2
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2
@onready var area_3d_2: Area3D = $"../../Area3D2"
var is_perfect = false


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


func _on_animation_player_2_animation_finished(anim_name: StringName) -> void:
	animation_player_2.play()

func _on_area_3d_2_body_entered(body: Node3D) -> void:
	if is_perfect:
		bell_sfx_2.queue_free()
		animation_player_2.queue_free()
		area_3d_2.queue_free()
		

func perfect_recipe():
	is_perfect = true
	bell_sfx_2.autoplay = true
	bell_sfx_2.playing = true
	animation_player_2.current_animation = "grandpa"
	animation_player_2.play()
