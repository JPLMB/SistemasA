extends CharacterBody2D

@export var speed := 90.0        # velocidade horizontal
@export var amplitude := 15.0     # altura da onda
@export var frequency := 5.0      # quão rápido a onda oscila
@export var damage := 4           # dano ao player

var time := 0.0
var start_y := 0.0
var direction := Vector2.LEFT  # ou LEFT, escolher ao instanciar

@onready var hitbox := $Area2D

func _ready():
	start_y = global_position.y
	hitbox.body_entered.connect(_on_body_entered)
	hitbox.area_entered.connect(_on_area_entered)

func _physics_process(delta):
	time += delta

	# movimento senoidal
	var offset_y = sin(time * frequency) * amplitude
	var pos := global_position
	pos.x += direction.x * speed * delta
	pos.y = start_y + offset_y
	global_position = pos

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)
		queue_free()

func _on_area_entered(area):
	# se levar tiro
	if area.is_in_group("bullet"):
		area.queue_free()
		queue_free()
