extends Line2D

@export var followee:Player

@export var trail_segments:int = 2
@export_range(0.0, 1.0, 0.05) var lerp_weight:float = 0.0

var trail:Line2D

func get_follow_point() -> Vector2:
	return followee.active_collision.global_position

func add_points(amount:int):
	if amount <= 0:
		return
	
	add_point(Vector2(randi_range(-10,10), randi_range(-10,10)))
	
	add_points(amount - 1)
 
func _ready() -> void:
	add_points(trail_segments)

func _process(delta: float) -> void:
	for i in get_point_count():
		# print(to_local(followee.global_position))
		if i == 0:
			set_point_position(i, to_local(get_follow_point()))
		else:
			set_point_position(i, lerp(get_point_position(i), get_point_position(i - 1), lerp_weight))
