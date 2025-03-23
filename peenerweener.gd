extends CharacterBody2D

@export var walk_speed = 200.0
@export var run_speed = 300.0
@export_range(0,1) var walk_acceleration = 0.2
@export_range(0,1) var run_acceleration = 0.03
@export_range(0,1) var deceleration = 0.14

@export var jump_force = -900.0
@export_range(0,1) var decelerate_on_jump_release = 0.5

@export var dash_speed = 500.0
@export var dash_max_distance = 100.0
@export var dash_curve: Curve
@export var dash_cooldown = 1.0

var is_dashing = false
var dash_start_position = 0
var dash_direction = 0
var dash_timer = 0

@onready var _animation_player = $AnimationPlayer

func _process(_delta):
	if velocity.y < 0:
		_animation_player.play("jump")
	else:
		_animation_player.play("idle")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= decelerate_on_jump_release

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction !=0:
		if Input.is_action_pressed("run") and abs(velocity.x) > 0:
			velocity.x = move_toward(velocity.x, direction * run_speed, run_speed * run_acceleration)
		elif Input.is_action_pressed("run"):
			velocity.x = move_toward(velocity.x, direction * run_speed, run_speed * run_acceleration * 2)
		else:
			velocity.x = move_toward(velocity.x, direction * walk_speed, walk_speed * walk_acceleration)
		$Sprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * deceleration)
		
	# Dash activation
	if Input.is_action_just_pressed("dash") and direction and not is_dashing and dash_timer <= 0:
		is_dashing = true
		dash_start_position = position.x
		dash_direction = direction
		dash_timer = dash_cooldown
	
	# Performs actual dash
	if is_dashing:
		var current_distance = abs(position.x - dash_start_position)
		if current_distance >= dash_max_distance or is_on_wall():
			is_dashing = false
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			velocity.y = 0
	
	if dash_timer > 0:
		dash_timer -= delta
	
	move_and_slide()
	
