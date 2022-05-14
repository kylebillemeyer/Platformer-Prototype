extends Node2D

var go_to_next_level
var go_to_reset_level
var next_level_path

var levels = {}

var dimensions

var player_scene = preload("res://Player.tscn")
var spike_scene = preload("res://obstacles/Spike.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var dynamicMap = get_node("../DynamicTileMap")
	
	var min_pos = Vector2.INF
	var max_pos = -Vector2.INF
	for pos in dynamicMap.get_used_cells():
		var tile = dynamicMap.get_cell(pos.x, pos.y)
		
		# insert auto gen stuff here
		match tile:
			2:
				create_default(pos, spike_scene)
			_:
				print("Could not create dynamic tile #" + str(tile))
		
		min_pos = Vector2(min(min_pos.x, pos.x), min(min_pos.y, pos.y))
		max_pos = Vector2(max(max_pos.x, pos.x), max(max_pos.y, pos.y))
		
	dimensions = (max_pos - min_pos) * Globals.grid_size
	
	var player = player_scene.instance()
	
	var entrance = get_node("Entrance")
	assert(entrance, "Level must have the path /Room/Entrance")

	player.set_position(entrance.get_position())
	add_child(player)
	
	for c in get_children():
		if c.get_class() == "Door" && c.next_level_path:
			#var path_parts = c.next_level_path.rsplit("/")
			#var level_path = "res://levels/" + path_parts[0] + ".tscn"
			#var level = load(level_path)
			#levels[c.next_level_path] = level
			continue

func _process(delta):
	if next_level_path:
		var tree = get_tree()
		
		var path_parts = next_level_path.rsplit("/")
		
		var level_path = "res://levels/" + path_parts[0] + ".tscn"
		tree.change_scene(level_path)
		
		var door_name = path_parts[1]
		var room = tree.get_root().find_node("Room*", true, false)
		LevelManager.spawn_door = door_name
		
	if go_to_reset_level:
		var tree = get_tree()
		tree.reload_current_scene()

func change_level(level_path):
	if (!level_path):
		print("No level path assigned to door. Cannot change levels.")
	elif !("/" in level_path):
		print("Level path must be of form 'Level [x]/Door [y]'. Cannot change levels.")
	else:
		next_level_path = level_path
		
func reset_level():
	go_to_reset_level = true
	
func create_default(pos, scene):
	var obstacle = scene.instance()
	obstacle.set_position(pos * Globals.grid_size + (Vector2.ONE * Globals.half_grid_size))
	add_child(obstacle)
