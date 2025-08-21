extends CharacterBody2D
class_name Player

## Movement Variables
const MAX_SPEED = 175.0

const ACCELERATION = 140.0
const AIR_ACCELERATION = 60.0

const FRICTION = 11.0
const AIR_FRICTION = 5.0

const JUMP_VELOCITY = -280.0

var is_in_velocity_cloud:bool = false

# Jump buffering / Coyote time
const COYOTE_TIME:float = 0.1
var coyote_time:float = 0.0

const JUMP_BUFFERING:float = 0.2
var jump_buffering:float = 0.0

# Wall jumping
const WALL_JUMP_VELOCITY:Vector2 = Vector2(MAX_SPEED,JUMP_VELOCITY) * 1.5

const LEFT_FLOOR_BUFFER:float = 0.2 # How long the player has to have been off the floor for them to stick to walls
var left_floor_buffer:float = 0.0

const SLIDE_ACCELERATION:float = 100.0
const SLIDE_SPEED:float = 150.0

# Animation and Collision
@onready var anim:AnimatedSprite2D = $AnimatedSprite2D

## Particles


var was_on_floor:bool = false

@onready var wall_particle:Particle = load("res://scene/particles/hit_wall.tscn").instantiate()


@onready var land_particle:PackedScene = load("res://scene/particles/land.tscn")

var active_collision:Node2D
func set_active_collision(to:Node2D):
	if to is not CollisionPolygon2D and to is not CollisionShape2D or to == active_collision:
		return
	
	active_collision = to
	
	for child in get_children():
		if child is CollisionPolygon2D or child is CollisionShape2D:
			child.set_deferred("disabled", true)
	
	to.set_deferred("disabled", false)

## Math and logic functions
func abs_highest(values:Array[float]) -> float:
	var abs_high = 0.0
	for value in values:
		if abs(value) > abs(abs_high):
			abs_high = value
	return abs_high

func is_positive(number:float) -> bool:
	return number / abs(number) > 0

# Match the value's sign to another value's sign (ie, 4, -10 -> -4)
func match_sign(value:float, to:float) -> float:
	if value == 0 or to == 0:
		return 0
	return abs(value) * (to/abs(to))

func xor(a:bool, b:bool) -> bool:
	return (a or b) and not (a and b)

func _ready() -> void:
	add_child(wall_particle)

func _physics_process(delta: float) -> void:
	
	
	if global_position.y + 8 > Global.lava_level and Global.round_active:
		Global.end_round.emit()
	
	# Add the gravity.
	if not is_on_floor() and not is_in_velocity_cloud:
		velocity += get_gravity() * delta
	
	## Jumping 
	
	# Jump Buffering
	jump_buffering = move_toward(jump_buffering, 0, delta)
	if Input.is_action_just_pressed("Jump"):
		jump_buffering = JUMP_BUFFERING
	
	# Coyote Time (and the left_floor_buffer)
	coyote_time = move_toward(coyote_time, 0, delta)
	left_floor_buffer = move_toward(left_floor_buffer, 0, delta)
	if is_on_floor():
		coyote_time = COYOTE_TIME
		left_floor_buffer = LEFT_FLOOR_BUFFER
		
	
	# Handle jump.
	if jump_buffering > 0 and coyote_time > 0:
		velocity.y = JUMP_VELOCITY
		
		jump_buffering = 0
		coyote_time = 0
	
	## Wall Jumping
	
	var wall_side:float = get_wall_normal().x
	if is_on_wall_only() and left_floor_buffer == 0:
		
		# Slow down upwards momentum significantly
		if velocity.y < 0:
			velocity.y /= 1.1
		
		# Override the gravity with slide acceleration
		velocity.y -= get_gravity().y * delta
		velocity.y += SLIDE_ACCELERATION * delta
		
		# Cap the slide speed
		if velocity.y > SLIDE_SPEED:
			velocity.y = SLIDE_SPEED
		
		if jump_buffering > 0:
			# Wall jump, applying the wall side as a multiplier to make the jump to the right side
			velocity = WALL_JUMP_VELOCITY * Vector2(wall_side, 1)
			jump_buffering = 0
	
	## Movement
	
	# Get the input direction
	var direction := Input.get_axis("Left", "Right")
	
	# If trying to move
	if direction:
		
		# IF the direction the player is going and the direction they want to go are different things
		var is_trying_to_turn:bool = xor(is_positive(velocity.x), is_positive(direction))
		
		# The next x velocity is whichever value is further from 0 (highest when absolute)
		var next_x_velocity:float = abs_highest([direction * MAX_SPEED, velocity.x]) * 0.99
		
		var current_acceleration = ACCELERATION if is_on_floor() else AIR_ACCELERATION
		
		# Override the velocity if you're trying to turn
		if is_trying_to_turn:
			next_x_velocity = direction * MAX_SPEED
			
			# Make it even harder to turn while midair
			if not is_on_floor():
				current_acceleration /= AIR_FRICTION
		
		# Move velocity.x towards where it should 
		# be via the current acceleration.
		velocity.x = move_toward(velocity.x, next_x_velocity, current_acceleration)
	# If not trying to move
	else:
		var current_friction:float = FRICTION if is_on_floor() else AIR_FRICTION
	
		# If not trying to move, slow down according to the current friction
		velocity.x = move_toward(velocity.x, 0, current_friction)
	
	## Animation
	
	# If moving at all
	if velocity != Vector2.ZERO:
		anim.flip_h = velocity.x < 0
		
		# Walking animation/collision if on floor
		if is_on_floor():
			anim.play("walking", abs(velocity.x) / 100)
			set_active_collision($WalkingCol)
		
		# Sliding animation/collision if on wall only
		elif is_on_wall_only():
			anim.play("sliding", velocity.y / 80)
			set_active_collision($SlideCol)
			
			# Flip the collision and animation,
			# depending on what side of the wall you're on
			active_collision.position.x = match_sign(active_collision.position.x, -wall_side)
			anim.flip_h = (wall_side + 1) / 2
		
		# Midair animation/collision if... midair, duh. (Not on floor or wall)
		else:
			anim.play("midair", (velocity.x + velocity.y) / 160)
			set_active_collision($MidAirCol)
	# Play idle animation and use walking collision if not moving
	else:
		set_active_collision($WalkingCol)
		anim.play("idle")
	
	## Particles
	
	# Make landing particles if hit the floor this frame.
	if not was_on_floor and is_on_floor():
		Global.make_particle.emit(land_particle, global_position + Vector2(0, 8))
	was_on_floor = is_on_floor() # Update for the next frame
	
	# Make wall sliding particles
	wall_particle.emitting = is_on_wall_only()
	wall_particle.global_position = global_position + Vector2(-8 * wall_side, 0)
	
	move_and_slide()
