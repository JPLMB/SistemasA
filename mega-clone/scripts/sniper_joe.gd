extends CharacterBody2D

@export var detection_range := 250.0
@export var fire_delay := 0.4
@export var burst_count := 3

const BULLET = preload("uid://kxqyudxlx6d2")


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_detector: Area2D = $PlayerDetector

var player: Node2D = null
var is_vulnerable := false
var is_attacking := false

func _ready():
	player_detector.body_entered.connect(_on_player_enter)
	player_detector.body_exited.connect(_on_player_exit)


func _on_player_enter(body):
	if body.name == "Player":
		player = body


func _on_player_exit(body):
	if body == player:
		player = null


func _physics_process(delta):
	face_player()

	if player and not is_attacking:
		attack()


func face_player():
	if not player:
		return

	# vira para a esquerda ou direita
	if player.global_position.x < global_position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false


func is_player_in_front() -> bool:
	if not player:
		return false

	var dir = sign(player.global_position.x - global_position.x)
	var facing = -1 if sprite.flip_h else 1
	return dir == facing


func attack():
	if not player:
		return

	if not is_player_in_front():
		return

	is_attacking = true
	is_vulnerable = false
	sprite.play("shield")  # parado com o escudo
	shoot_burst()


func shoot_burst() -> void:
	# sequência de 3 tiros
	for i in range(burst_count):
		await get_tree().create_timer(fire_delay).timeout
		shoot_once()

	# Depois da rajada, fica vulnerável por 1 segundo
	is_vulnerable = true
	sprite.play("vulnerable")
	await get_tree().create_timer(1.0).timeout

	is_vulnerable = false
	is_attacking = false
	sprite.play("shield")


func shoot_once():
	var b = BULLET.instantiate()
	get_parent().add_child(b)

	# posição do cano do tiro
	var offset_x = -12 if sprite.flip_h else 12
	b.global_position = global_position + Vector2(offset_x, -4)

	# direção
	b.direction = Vector2.LEFT if sprite.flip_h else Vector2.RIGHT
