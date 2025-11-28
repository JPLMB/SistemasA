extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_bar: AnimatedSprite2D = $"../HUD/Control/BoxContainer/LifeBar"

func _physics_process(delta: float) -> void:
	
	# DEBUG -----------------------------------------
	if Input.is_action_just_pressed("debug_damage"):
		life_bar.take_damage_animated(1)

	if Input.is_action_just_pressed("debug_heal"):
		life_bar.heal(1)
	# -----------------------------------------------

	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("idle")
		else: animated_sprite_2d.play("moving")
	else: animated_sprite_2d.play("jump")
	
	if direction < 0:
		animated_sprite_2d.flip_h = true
	elif direction > 0:
		animated_sprite_2d.flip_h = false
	
	if direction:
		velocity.x = direction * SPEED * 0.5
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
