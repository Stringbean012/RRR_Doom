extends CharacterBody3D


@export var RUN_SPEED = 100
@export var SPEED = 10
@export var TURN_SPEED = 5.0
@export var GRAVITY_MULTIPLIER = 100.0
@export var CAMERA_Y_NORMAL = 1.81
@export var CAMERA_Y_SLITHER = 0.0
@onready var camera: PlayerCamera = $Camera3D

var strafing: bool
var running: bool

func _process(delta: float) -> void:
	strafing = Input.is_action_pressed("strafe")
	running = Input.is_action_pressed("run")
	camera.tween_y(CAMERA_Y_SLITHER if running else  CAMERA_Y_NORMAL)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += GRAVITY_MULTIPLIER * get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed = RUN_SPEED if running else SPEED
	camera.bobbing = false
	if strafing:
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			camera.bobbing = true
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else:
		if input_dir.y != 0:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			camera.bobbing = true
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		
		if input_dir.x != 0:
			rotate_y(-input_dir.x * TURN_SPEED * delta)

	move_and_slide()
