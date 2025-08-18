extends Node2D
class_name Main

func _ready() -> void:
	Global.make_particle.connect(_on_make_particle)

func _on_make_particle(particle:PackedScene, at:Vector2):
	var new:Particle = particle.instantiate()
	
	new.emitting = true
	add_child(new)
	
	new.global_position = at
