extends Area2D
@onready var timer: Timer = $Timer
var cached_player = null

func _on_body_entered(body):
	if body.is_in_group("player"):
		cached_player = body
		timer.start()

func _on_timer_timeout():
	if cached_player:
		cached_player.die()
