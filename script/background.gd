extends TileMapLayer
class_name Background

@export var camera:Camera

const FILL_FREQUENCY:float = 3.0 # How often in seconds
var fill_time:float = 0.0

@export var background_indices:Array[Vector2i] = [
	Vector2i(2,0),
	Vector2i(3,0),
	Vector2i(2,1),
	Vector2i(3,1),
	Vector2i(2,2),
	Vector2i(3,2),
	Vector2i(2,3),
	Vector2i(3,3),
]

@onready var camera_size = get_viewport_rect().size / camera.zoom + Vector2(25, 25)
func get_camera_bounds():
	
	var camera_rect:Rect2 = Rect2(get_viewport_rect().position, camera_size)
	
	camera_rect.position += camera.global_position - (camera_rect.size / camera.zoom * 1.5)
	
	return camera_rect

func fill_empty_space():
	var cam_rect:Rect2 = get_camera_bounds()
	
	for i in range(cam_rect.size.x):
		for j in range(cam_rect.size.y):
			var cell_position:Vector2i = local_to_map(to_local(cam_rect.position + Vector2(i,j)))
			# print(get_cell_source_id(cell_position))
			if get_cell_source_id(cell_position) == -1:
				set_cell(cell_position, tile_set.get_source_id(0), background_indices.pick_random())

func _process(delta: float) -> void:
	if fill_time <= 0:
		fill_empty_space()
		fill_time = FILL_FREQUENCY
	fill_time = move_toward(fill_time, 0, delta)
