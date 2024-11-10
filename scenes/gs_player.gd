extends CharacterBody3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var MOUSE_SENSITIVITY = 0.003
@export var GRAVITY = 9.8

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var inventory = $Head/Camera3D/Inventory

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event.is_action_pressed("drop") and inventory.held_items.size() > 0:
		inventory.drop_item()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")	
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	move_and_slide()

func pickup_item(item_mesh, should_destroy, item_type = null):
	if inventory:
		return inventory.pickup_item(item_mesh, should_destroy, item_type)
	return false
