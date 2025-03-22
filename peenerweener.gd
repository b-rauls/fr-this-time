extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -900.0

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
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction !=0:
		velocity.x = direction * SPEED
		$Sprite2D.flip_h=direction <0
	else:
		velocity.x = move_toward(velocity.x, 0, 20)
		
		
	move_and_slide()
	
