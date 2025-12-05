extends Area2D
@export var speed := 200.0
var direction := Vector2.RIGHT

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(_body: Node2D) -> void:
	queue_free()

func _on_visible_on_screen_notifier_2d_visibility_changed() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Player":
		Input.action_press("H")
		queue_free()
