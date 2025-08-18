extends Line2D
class_name TrailSegment

var child_segment:TrailSegment

# Set the 0th index to 0,0 on init, set the 1th index to given position

func update_position(to:Vector2, lerp_weight:float):
	set_point_position(1, to_local(to))
	set_point_position(0, lerp(get_point_position(0), to_local(to), lerp_weight))
	
	if child_segment != null:
		child_segment.update_position(to_global(lerp(get_point_position(0), to_local(to), lerp_weight)), lerp_weight)

func _ready() -> void:
	var parent = get_parent()
	if parent is TrailSegment:
		parent.child_segment = self
	
	add_point(Vector2.ZERO, 0)
	add_point(Vector2.ZERO, 1)
