extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_bar: AnimatedSprite2D = $"../HUD/Control/BoxContainer/LifeBar"

@export var max_health := 29
var current_health := max_health

signal health_changed(current: int, max: int)
signal damaged(amount: int)
signal healed(amount: int)

const BULLET = preload("uid://kxqyudxlx6d2")
@export var shoot_offset := Vector2(20, -5)

func heal(amount: int):
	current_health = clamp(current_health + amount, 0, max_health)
	emit_signal("healed", amount)
	emit_signal("health_changed", current_health, max_health)

func take_damage(amount: int):
	current_health = clamp(current_health - amount, 0, max_health)
	emit_signal("damaged", amount)
	emit_signal("health_changed", current_health, max_health)

	if current_health <= 0:
		die()

func die():
	print("Player morreu! Reiniciando...")
	get_tree().call_deferred("reload_current_scene")

func _ready():
	add_to_group("player")
	print("Player groups:", get_groups())
	emit_signal("health_changed", current_health, max_health)

func _physics_process(delta: float) -> void:
	
	# DEBUG -----------------------------------------
	if Input.is_action_just_pressed("debug_damage"):
		take_damage(1)

	if Input.is_action_just_pressed("debug_heal"):
		heal(1)
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
		
	if Input.is_action_just_pressed("shoot"):
		shoot()

	move_and_slide()

func shoot():
	var bullet = BULLET.instantiate()

	# escolhe direção e ajusta o offset dependendo do lado
	var offset = shoot_offset

	if animated_sprite_2d.flip_h:
		offset.x *= -1
		bullet.direction = Vector2.LEFT
	else:
		bullet.direction = Vector2.RIGHT

	bullet.position = global_position + offset

	# adiciona bullet no mesmo nível do player (ou acima)
	get_parent().add_child(bullet)
