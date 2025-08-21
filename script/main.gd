extends Node
class_name Main


@onready var world:Node2D = $World
@onready var player:Player = get_tree().get_first_node_in_group("Player")
@onready var spawnpoint:Vector2 = $World/Spawnpoint.global_position
@onready var default_scoreboard:String = $World/Score/Label.text

const MAX_LEVEL_AREA:int = 4

var levels:Array[PackedScene] = get_levels()
func get_levels() -> Array[PackedScene]:
	
	var levels:Array[PackedScene]
	
	var path = "res://scene/level/"
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		# While the current file is a file
		while file_name != "":
			# Found a directory
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			# Found a file
			else:
				# Load the scene 
				var potential_level_scene = load(path + file_name)
				
				# If it's packed, check if an instance is a leve
				if potential_level_scene is PackedScene:
					var potential_level = potential_level_scene.instantiate()
					
					# If it is, add the packedscene to the list
					if potential_level is Level:
						levels.append(potential_level_scene)
					
					# Free memory afterwards :D
					potential_level.queue_free()
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

	return levels

@export var loaded_levels:Array[Level]

func load_level(coordinates:Vector2):
	# Load a random level up, add it to the world and the list of levels
	var new:Level = levels.pick_random().instantiate()
	
	world.add_child(new)
	loaded_levels.append(new)
	
	new.global_position = from_level_grid(coordinates)
func load_neighbor_levels():
	
	var player_coordinates:Vector2 = to_level_grid(player.global_position)
	
	var load_coordinates:Array[Vector2] = [
		player_coordinates + Vector2(0,0),
		player_coordinates + Vector2(0,1),
		player_coordinates + Vector2(1,0),
		player_coordinates + Vector2(-1,0),
		player_coordinates + Vector2(0,-1),
		player_coordinates + Vector2(-1,-1),
		player_coordinates + Vector2(1,-1),
		player_coordinates + Vector2(1,1),
		player_coordinates + Vector2(-1,1)
	]
	
	# Check every level to see if it's in one of the load spots
	for level in loaded_levels:
		
		# If so, ignore that coordinate for this pass.
		
		var coords = to_level_grid(level.global_position)
		load_coordinates.erase(coords)
	for coordinate in load_coordinates:
		load_level(coordinate)
	
	pass
func unload_far_levels():
	var player_coordinates = to_level_grid(player.global_position)
	for level in loaded_levels:
		var coordinates = to_level_grid(level.global_position)
		
		var distance = abs((coordinates.x + coordinates.y) - (player_coordinates.x + player_coordinates.y))
		
		if distance > MAX_LEVEL_AREA:
			loaded_levels.erase(level)
			level.queue_free()

func from_level_grid(coordinates:Vector2):
	return coordinates * Vector2(48 * 16, 64 * 16)

func to_level_grid(position:Vector2):
	return floor(position / Vector2(48 * 16,64 * 16))

func _ready() -> void:
	Global.make_particle.connect(_on_make_particle)
	
	Global.play_sfx.connect(_on_play_sfx)

func _process(delta: float) -> void:
	load_neighbor_levels()
	unload_far_levels()
	
	$CanvasLayer/UI.modulate.a = move_toward($CanvasLayer/UI.modulate.a, 1.0 if Global.fading else 0.0, delta)
	if Global.fading and $CanvasLayer/UI.modulate.a >= 1.0:
		$World/Tutorial.visible = false
		
		Global.lava_level = 250.0
		Global.fading = false
		
		player.global_position = spawnpoint
		
		$World/Score.visible = true
		$World/Score/Label.text = default_scoreboard.replace("_", str(Global.score)).replace("-", str(Global.highscore))

## Audio

@onready var audio_host:Node = $AudioHost

const MAX_CONCURRENT_SOUND_EFFECTS:int = 3
func _on_play_sfx(sfx:AudioStream):
	var sfx_player:AudioStreamPlayer
	
	var current_sfx_players:int = 0
	
	for child in audio_host.get_children():
		# For every audiohost child
		if child is AudioStreamPlayer and child.name == "SFXPlayer":
			
			current_sfx_players += 1 # Count towards the sfx player
			
			# If it's not working, use it for this SFX
			if not child.playing and sfx_player == null:
				sfx_player = child
	
	# If there were no available players and it's not at max,
	# make a new one and use that.
	if sfx_player == null and current_sfx_players < MAX_CONCURRENT_SOUND_EFFECTS:
		sfx_player = AudioStreamPlayer.new()
		
		sfx_player.name = "SFXPlayer"
		sfx_player.bus = "SFX"
		
		audio_host.add_child(sfx_player)
	
	# If a player was found &/ made, play the sound effect on it.
	if sfx_player != null:
		sfx_player.stream = sfx
		sfx_player.play()

func _on_make_particle(particle:PackedScene, at:Vector2):
	var new:Particle = particle.instantiate()
	
	new.emitting = true
	world.add_child(new)
	
	new.global_position = at
