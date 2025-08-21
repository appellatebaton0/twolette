extends Camera2D
class_name Camera

@export var player:Player

# How fast the camera follows the player, 0 being not at all, 1 being instant.
@export var follow_lerp:float = 0.1

func get_follow_point() -> Vector2:
	
	# Set the follow point to the player's position
	var player_point:Vector2 = player.global_position
	
	# Add the velocity with a dampener for some simple follow-ahead
	player_point += player.velocity / 5
	
	# Lerp between the current position and the player point.
	var follow_point = lerp(global_position, player_point, follow_lerp)
	
	#
	#if follow_point.x < -12*16:
		#follow_point.x = -12*16
	#elif follow_point.x > 12*16:
		#follow_point.x = 12*16
	
	return follow_point
	
func _process(delta: float) -> void:
	global_position = get_follow_point()
