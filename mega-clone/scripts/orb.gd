extends Area2D

@export var sfx_victory: AudioStream     # música de vitória

var activated := false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if activated:
		return
		
	if body.is_in_group("player"):
		activated = true
		_start_victory_sequence(body)

func _start_victory_sequence(player):
	# Desliga física do player
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO

	# Desliga inputs

	# Toca música de vitória globalmente
	_play_music(sfx_victory)

	# Opcional: animação de ORB subindo
	animate_orb()

	# Ao terminar a música → finalizar jogo
	var audio := _play_music(sfx_victory)
	await audio.finished

	_end_game()

func animate_orb():
	var tween := create_tween()
	tween.tween_property(self, "global_position:y", global_position.y - 80, 2.0)

func _play_music(stream: AudioStream) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.autoplay = false
	p.bus = "Music"
	p.volume_db = 0
	get_tree().current_scene.add_child(p)
	p.play()
	return p

func _end_game():
	# Congelar tudo
	get_tree().paused = true

	# Aqui você pode:
	# - Mostrar "YOU WIN!"
	# - Voltar ao título
	# - Sair do jogo
	print("FIM DO JOGO!")
