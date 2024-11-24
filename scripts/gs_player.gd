extends CharacterBody3D

@export var SPEED = 4.0
@export var JUMP_VELOCITY = 4.5
@export var MOUSE_SENSITIVITY = 0.003
@export var GRAVITY = 9.8
@export var SPRINT_SPEED = 2.5

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var inventory = $Head/Camera3D/Inventory

const freq = 3.5
const amp = 0.08
var t = 0.0

var can_play = true
signal step

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if event.is_action_pressed("drop") and inventory.held_items.size() > 0:
		inventory.drop_item()

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0  # Reset vertical velocity when on the ground

	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		emit_signal("step")
	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var ACCELERATION = 25.0  # Acceleration rate
	var DECELERATION = 15.0  # Deceleration rate

	# Check if sprint action is pressed
	if Input.is_action_just_pressed("sprint"):
		SPEED += SPRINT_SPEED  # Use sprint speed
	if Input.is_action_just_released("sprint"):
		SPEED -= SPRINT_SPEED

	var target_velocity = Vector3.ZERO

	if direction != Vector3.ZERO:
		# Calculate target velocity based on input
		target_velocity = direction * SPEED
		# Accelerate towards target velocity
		velocity.x = move_toward(velocity.x, target_velocity.x, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, ACCELERATION * delta)
	else:
		# Decelerate to a stop when no input
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0, DECELERATION * delta)
		
	t += delta * velocity.length() * float(is_on_floor())
	
	_headbob(t)

	# Move the player
	move_and_slide()

func pickup_item(item_mesh, should_destroy, item_type = null):
	if inventory:
		return inventory.pickup_item(item_mesh, should_destroy, item_type)
	return false

func find_collector_in_range() -> Node3D:
	if inventory and inventory.collector:
		var collector = inventory.collector
		var distance = global_position.distance_to(collector.global_position)
		if distance <= 3:
			return collector
	return null
	
func _headbob(time):
	var pos = Vector3.ZERO
	pos.y = sin(time * freq) * amp
	pos.x = cos(time * freq / 2) * amp
	
	var low_pos = amp - 0.05
	if pos.y > -low_pos:
		can_play = true
		
	if pos.y < -low_pos and can_play:
		can_play = false
		emit_signal("step")