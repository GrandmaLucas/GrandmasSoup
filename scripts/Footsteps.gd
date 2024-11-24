extends Node3D

@export var footstep_sounds : Array[AudioStreamMP3]
@onready var player = get_parent()

func _ready() -> void:
	player.step.connect(play_sound)

func play_sound():
	var audio_player = AudioStreamPlayer3D.new()
	var random_index = randi_range(0, footstep_sounds.size() - 1)
	audio_player.stream = footstep_sounds[random_index]
	audio_player.pitch_scale = randf_range(0.9, 1.1)
	add_child(audio_player)
	audio_player.volume_db = -30
	audio_player.play()
	audio_player.finished.connect(func destroy(): audio_player.queue_free())
