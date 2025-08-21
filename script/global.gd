extends Node

signal play_sfx(sfx:AudioStream)

signal make_particle(particle:PackedScene, at:Vector2)

signal start_round
signal end_round

var round_active:bool = false

func _ready() -> void:
	start_round.connect(_on_start_round)
	end_round.connect(_on_end_round)

func _on_start_round():
	round_active = true
func _on_end_round():
	round_active = false
