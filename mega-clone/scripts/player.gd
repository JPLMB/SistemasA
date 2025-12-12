extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_bar: AnimatedSprite2D = $"../HUD/Control/BoxContainer/LifeBar"
@onready var sfx: AudioStreamPlayer2D = $SFX

@export var max_health := 29
var current_health := max_health

@export var coyote_time := 0.1
var coyote_timer := 0.0

signal health_changed(current: int, max: int)
signal damaged(amount: int)
signal healed(amount: int)

const BULLET = preload("uid://kxqyudxlx6d2")
@export var shoot_offset := Vector2(20, -5)

@export var sfx_jump: AudioStream
@export var sfx_shoot: AudioStream
@export var sfx_damage: AudioStream
@export var sfx_die: AudioStream

var was_on_floor := false

func _play_sfx(stream: AudioStream):
	if stream == null:
		return
	sfx.stream = stream
	sfx.play()

func heal(amount: int):
	current_health = clamp(current_health + amount, 0, max_health)
	emit_signal("healed", amount)
	emit_signal("health_changed", current_health, max_health)

func take_damage(amount: int):
	_play_sfx(sfx_damage)
	current_health = clamp(current_health - amount, 0, max_health)
	emit_signal("damaged", amount)
	emit_signal("health_changed", current_health, max_health)

	if current_health <= 0:
		die()

func die():
	print("Player morreu!")

	_play_sfx(sfx_die)

	set_physics_process(false)
	set_process(false)

	var sprite := $AnimatedSprite2D

	# Piscar estilo Mega Man NES
	for i in range(4):
		sprite.visible = false
		await get_tree().create_timer(0.1).timeout
		sprite.visible = true
		await get_tree().create_timer(0.1).timeout

	# Desaparece de vez
	sprite.visible = false

	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()

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
	
	# Atualiza coyote time
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0

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
	
	# --- SFX do Mega Man: som ao aterrissar ---
	var on_floor_now = is_on_floor()
	if on_floor_now and not was_on_floor:
		_play_sfx(sfx_jump)
	was_on_floor = on_floor_now

func shoot():
	_play_sfx(sfx_shoot)
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
