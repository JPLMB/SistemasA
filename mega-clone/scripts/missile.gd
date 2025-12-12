extends CharacterBody2D

@export var speed := 90.0
@export var amplitude := 15.0
@export var frequency := 5.0
@export var damage := 4

var time := 0.0
var start_y := 0.0
var direction := Vector2.LEFT

@onready var hitbox := $Area2D
@export var sfx_hit: AudioStream

func _ready():
	start_y = global_position.y
	hitbox.body_entered.connect(_on_body_entered)
	hitbox.area_entered.connect(_on_area_entered)

func _physics_process(delta):
	time += delta

	var offset_y = sin(time * frequency) * amplitude
	var pos := global_position
	pos.x += direction.x * speed * delta
	pos.y = start_y + offset_y
	global_position = pos

func play_explosion_sfx():
	var temp_sfx := AudioStreamPlayer2D.new()
	temp_sfx.stream = sfx_hit
	temp_sfx.global_position = global_position
	temp_sfx.bus = "SFX"
	temp_sfx.top_level = true
	
	get_tree().current_scene.add_child(temp_sfx)
	temp_sfx.play()
	temp_sfx.connect("finished", temp_sfx.queue_free)

func _on_body_entered(body):
	if body.is_in_group("player"):
		play_explosion_sfx()
		body.take_damage(damage)
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("bullet"):
		play_explosion_sfx()
		area.queue_free()
		queue_free()
