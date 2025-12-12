extends Area2D

@export var victory_music: AudioStream
@export var next_scene_path: String = "res://scenes/title_screen.tscn"

var _activated := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if _activated:
		return
	if not body.is_in_group("player"):
		return

	_activated = true

	# Esconde o orb
	visible = false
	$CollisionShape2D.disabled = true

	# --- PARAR A MÚSICA ATUAL DO JOGO ---
	for m in get_tree().get_nodes_in_group("music"):
		if m is AudioStreamPlayer:
			m.stop()

	# --- TOCAR A MÚSICA DE VITÓRIA ---
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = victory_music
	player.play()

	# Esperar a música terminar
	await player.finished

	# Mudar de cena
	get_tree().change_scene_to_file(next_scene_path)
