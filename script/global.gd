extends Node

signal play_sfx(sfx:AudioStream)

signal make_particle(particle:PackedScene, at:Vector2)

signal start_round
signal end_round

var round_active:bool = false
var lava_level:float = 250.0

var fading:bool = false

var score:float = 0.0
var highscore:float = 0.0

func _ready() -> void:
	start_round.connect(_on_start_round)
	end_round.connect(_on_end_round)

func _on_start_round():
	round_active = true
func _on_end_round():
	
	score = floor(abs(lava_level - 120)) / 10
	
	if highscore < score:
		highscore = score
	
	round_active = false
	fading = true
