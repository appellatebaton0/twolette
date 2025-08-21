extends Node2D
class_name Lava

@onready var player:Player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	global_position.y = Global.lava_level
	
	if Global.round_active:
		Global.lava_level -= 0.25
		Global.lava_level -= 0.2 * (floor(abs( player.global_position.y - Global.lava_level) / 100))
		
