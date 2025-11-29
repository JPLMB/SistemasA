extends Area2D

@export var speed := 600.0
var direction := Vector2.RIGHT  # Será configurada ao instanciar

func _physics_process(delta):
	position += direction * speed * delta * 0.7

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
