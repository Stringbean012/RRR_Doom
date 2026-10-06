extends CharacterBody3D

var speed := 3.0
var acceleration := 10.0
var turn_speed := 8.0
var sight_range := 25.0
var attack_damage := 10
var attack_cooldown := 1.0
var repath_interval := 0.2
var use_line_of_sight := false     
var model_yaw_offset_deg := 0.0     

var anim_idle := "idle"
var anim_walk := "walk"
var anim_attack := "attack"

enum State { IDLE, CHASE, ATTACK }

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var ray: RayCast3D = $RayCast3D
@onready var attack_area: Area3D = $Area3D

var player: Node3D
var state := State.IDLE
var player_in_range := false
var attack_timer := 0.0
var repath_timer := 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	
	if not attack_area.body_entered.is_connected(_on_area_3d_body_entered):
		attack_area.body_entered.connect(_on_area_3d_body_entered)
	if not attack_area.body_exited.is_connected(_on_area_3d_body_exited):
		attack_area.body_exited.connect(_on_area_3d_body_exited)

	
	await get_tree().physics_frame


func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	attack_timer = max(attack_timer - delta, 0.0)
	repath_timer -= delta

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	_update_state()

	match state:
		State.IDLE:
			_stop_horizontal(delta)
			_play(anim_idle)
		State.CHASE:
			_chase(delta)
			_play(anim_walk)
		State.ATTACK:
			_stop_horizontal(delta)
			_face(player.global_position, delta)
			_try_attack()

	move_and_slide()


func _update_state() -> void:
	if player_in_range:
		state = State.ATTACK
	elif _can_see_player():
		state = State.CHASE
	else:
		state = State.IDLE


func _can_see_player() -> bool:
	if global_position.distance_to(player.global_position) > sight_range:
		return false
	if not use_line_of_sight:
		return true

	
	ray.target_position = ray.to_local(player.global_position + Vector3.UP * 1.0)
	ray.force_raycast_update()
	return ray.is_colliding() and ray.get_collider() == player

func _chase(delta: float) -> void:
	if repath_timer <= 0.0:
		nav.target_position = player.global_position
		repath_timer = repath_interval

	if nav.is_navigation_finished():
		_stop_horizontal(delta)
		return

	var next_pos := nav.get_next_path_position()
	var dir := global_position.direction_to(next_pos)
	dir.y = 0.0
	dir = dir.normalized()

	var target_vel := dir * speed
	velocity.x = move_toward(velocity.x, target_vel.x, acceleration * delta * speed)
	velocity.z = move_toward(velocity.z, target_vel.z, acceleration * delta * speed)

	_face(global_position + dir, delta)


func _try_attack() -> void:
	if attack_timer > 0.0:
		return
	attack_timer = attack_cooldown
	_play(anim_attack, true)

	if player.has_method("take_damage"):
		player.take_damage(attack_damage)
	else:
		print("ATTACK! (add a take_damage(amount) method to the player)")

func _stop_horizontal(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, acceleration * delta * speed)
	velocity.z = move_toward(velocity.z, 0.0, acceleration * delta * speed)


func _face(target: Vector3, delta: float) -> void:
	var flat := target - global_position
	flat.y = 0.0
	if flat.length() < 0.05:
		return
	var target_yaw := atan2(-flat.x, -flat.z) + deg_to_rad(model_yaw_offset_deg)
	rotation.y = lerp_angle(rotation.y, target_yaw, turn_speed * delta)


func _play(anim_name: String, restart := false) -> void:
	if anim == null or not anim.has_animation(anim_name):
		return
	if restart or anim.current_animation != anim_name:
		anim.play(anim_name)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
