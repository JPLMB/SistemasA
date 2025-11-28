extends AnimatedSprite2D

@export var max_health := 28
var current_health := max_health

func update_life_bar():
	var frame_index = max_health - current_health
	frame_index = clamp(frame_index, 0, max_health)
	frame = frame_index

func set_health(value):
	current_health = clamp(value, 0, max_health)
	update_life_bar()

func take_damage(amount):
	set_health(current_health - amount)

func heal(amount):
	set_health(current_health + amount)
