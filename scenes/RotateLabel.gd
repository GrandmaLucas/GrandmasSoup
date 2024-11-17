extends Label3D

@export var player: Node3D

func _process(_delta):
	if player:
		look_at(player.global_transform.origin, Vector3(0, 1, 0))
		rotation.y += PI
		rotation.x = 0
		rotation.z = 0
