extends Node2D

# Declare member variables here. Examples:
export var width = 1000
export var height = 500
export(String) var default_spawn

var go_to_next_level
var go_to_reset_level
var next_level_path

var levels = {}

func set_default_spawn(path):
	default_spawn = path

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_scene = load("res://Player.tscn")
	var spawn_door = get_node(default_spawn)
	spawn_door.active = false
	
	var player = player_scene.instance()
	player.set_position(spawn_door.get_position())
	add_child(player)
	
	for c in get_children():
		if "Door" in c.get_name() && c.next_level_path:
			var path_parts = c.next_level_path.rsplit("/")
			var level_path = "res://levels/" + path_parts[0] + ".tscn"
			var level = load(level_path)
			levels[c.next_level_path] = level

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if next_level_path:
		var path_parts = next_level_path.rsplit("/")
		var door_name = path_parts[1]
		
		var root = get_tree().root
		var current_level = get_parent()
		root.remove_child(current_level)
		
		var level = levels[next_level_path].instance()
		level.get_node("Room").set_default_spawn(door_name)
		root.add_child(level)
		
	if go_to_reset_level:
		get_parent().get_tree().reload_current_scene()

func change_level(level_path):
	if (!level_path):
		print("No level path assigned to door. Cannot change levels.")
	elif !("/" in level_path):
		print("Level path must be of form 'Level [x]/Door [y]'. Cannot change levels.")
	else:
		next_level_path = level_path
		
func reset_level():
	go_to_reset_level = true
