extends Node2D
class_name Lava

func _process(delta: float) -> void:
	global_position.y = Global.lava_level
	
	if Global.round_active:
		Global.lava_level -= 0.15
