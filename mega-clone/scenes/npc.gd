extends CharacterBody2D

@export var speed: float = 50.0
@export var health: int = 1

var direction := -1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Area2D


func _ready():
	hitbox.body_entered.connect(_on_body_entered)
	hitbox.area_entered.connect(_on_area_entered)


func _physics_process(_delta):
	velocity.x = direction * speed
	move_and_slide()

	if is_on_wall():
		direction *= -1
		sprite.flip_h = direction > 0


func _on_body_entered(body):
	if body.name == "Player":
		if Input.is_action_just_pressed("debug_damage"):
			take_damage()


func _on_area_entered(area):
	if area.name == "Bullet":
		take_damage()


func take_damage():
	health -= 1
	if health <= 0:
		die()


func die():
	queue_free()
