extends CharacterBody2D

@export var speed: float = 50.0
@export var health: int = 3
@export var direction_change_time := 2.0

var direction := -1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Area2D
@onready var direction_timer: Timer = null

@export var sfx_hit: AudioStream

func _spawn_sfx(stream: AudioStream):
	if stream == null:
		return
	
	var temp := AudioStreamPlayer2D.new()
	temp.stream = stream
	temp.global_position = global_position
	temp.bus = "SFX"
	temp.top_level = true

	get_tree().current_scene.add_child(temp)

	temp.play()
	temp.connect("finished", temp.queue_free)

func _ready():
	hitbox.body_entered.connect(_on_body_entered)
	hitbox.area_entered.connect(_on_area_entered)

	# Garantir Timer
	if has_node("DirectionTimer"):
		direction_timer = $DirectionTimer
	else:
		direction_timer = Timer.new()
		direction_timer.name = "DirectionTimer"
		add_child(direction_timer)

	direction_timer.wait_time = direction_change_time
	direction_timer.timeout.connect(_on_direction_timer_timeout)
	direction_timer.start()

func _physics_process(_delta):
	velocity.x = direction * speed
	move_and_slide()

	if is_on_wall():
		_reverse_direction()

func _on_direction_timer_timeout():
	_reverse_direction()

func _on_body_entered(body):
	print("Algo entrou na hitbox:", body)
	if body.is_in_group("player"):
		body.take_damage(3)

func _on_area_entered(area):
	if area.is_in_group("bullet"):
		take_damage()
		area.queue_free()

func take_damage():
	_spawn_sfx(sfx_hit)
	health -= 1
	if health <= 0:
		die()

func die():
	queue_free()

func _reverse_direction():
	direction *= -1
	sprite.flip_h = direction > 0
