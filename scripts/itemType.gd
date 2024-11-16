# item_type.gd
@tool
extends Resource
class_name ItemType

@export var id: String
@export var display_name: String
@export var held_scale: Vector3 = Vector3(0.3, 0.3, 0.3)  # Default scale
@export var rotation_offset: Vector3 = Vector3.ZERO  # Additional rotation offset
@export var position_offset: Vector3 = Vector3.ZERO  # Additional position offset
