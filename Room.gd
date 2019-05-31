extends Node2D

# Declare member variables here. Examples:
export var width = 1000
export var height = 500

var go_to_next_level
var go_to_reset_level
var next_level_path

var levels = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_scene = load("res://Player.tscn")
	var spawn_door = get_node(LevelManager.spawn_door)
	spawn_door.active = false
	
	var player = player_scene.instance()
	player.set_position(spawn_door.get_position() + Vector2(0, 25))
	add_child(player)
	
	for c in get_children():
		if "Door" in c.get_name() && c.next_level_path:
			var path_parts = c.next_level_path.rsplit("/")
			var level_path = "res://levels/" + path_parts[0] + ".tscn"
			#var level = load(level_path)
			#levels[c.next_level_path] = level
			
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
