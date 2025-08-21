extends GPUParticles2D
class_name Particle

## If checked and the particle is one shot, this instance will queue free automatically on finishing.
@export var free_once_done:bool = true

func _on_finished() -> void:
	if free_once_done:
		queue_free()
