extends Area2D
class_name VelocityCloud

@export var DELAY:float = 1.0
var delay = 0.0

@export var velocity_multiplier:float = 1

@export var max_velocity:Vector2 = Vector2(300.0, 300.0)

## Math and logic

# Match the value's sign to another value's sign (ie, 4, -10 -> -4)
func match_sign(value:float, to:float) -> float:
	if value == 0 or to == 0:
		return 0
	return abs(value) * (to/abs(to))

# Match sign but for vectors, just cause it's simpler.
func vec_match_sign(value:Vector2, to:Vector2) -> Vector2:
	return Vector2(match_sign(value.x, to.x), match_sign(value.y, to.y))

# Returns if any part of the velocity is over the max velocity
func is_over_terminal(velocity:Vector2):
	return abs(velocity.x) > abs(max_velocity.x) or abs(velocity.y) > abs(max_velocity.y)

func _process(delta: float) -> void:
	if delay == 0:
		for body in get_overlapping_bodies():
			if body is Player: # For every player in this cloud
				
				# Apply the multiplier and tell the player it's in the cloud
				body.velocity *= velocity_multiplier
				body.is_in_velocity_cloud = true
				
				# IF moving too fast, set the velocity to its max output.
				if is_over_terminal(body.velocity):
					body.velocity = vec_match_sign(max_velocity, body.velocity)
				
				delay = DELAY # Start waiting for DELAY seconds.
	else:
		delay = move_toward(delay, 0, delta)

# Tell the player it's not in a cloud anymore.
func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.is_in_velocity_cloud = false
