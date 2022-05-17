extends Node2D

export(String) var next_level_path

var should_load_next_level = false
var should_reset_level = false
var entrance
var exit
var dimensions
var min_x
var min_y
var max_x
var max_y

var player_scene = preload("res://Player.tscn")
var spike_scene = preload("res://dynamic/obstacles/Spike.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    if (!next_level_path):
        print("No level path assigned to door. Cannot exit level.")
    
    entrance = get_node("Entrance")
    assert(entrance, "Level must have the path /Room/Entrance")
    
    exit = get_node("Exit")
    assert("Level must have the path /Room/Exit")
    exit.connect("door_triggered", self, "load_next_level")
    
    calculate_dimensions()
    
    generate_obstacles_from_tiles()
    spawn_player()

func _process(delta):
    var tree = get_tree()
    
    if should_load_next_level:
        var level_path = "res://levels/" + next_level_path + ".tscn"
        tree.change_scene(level_path)
    elif should_reset_level:
        tree.reload_current_scene()

func load_next_level():
    should_load_next_level = true
        
func reset_level():
    should_reset_level = true
    
func calculate_dimensions():
    var staticMap = get_node("../StaticTileMap")
    
    min_x = INF
    min_y = INF
    max_x = -INF
    max_y = -INF
    for pos in staticMap.get_used_cells():
        min_x = min(min_x, pos.x)
        min_y = min(min_y, pos.y)
        max_x = max(max_x, pos.x)
        max_y = max(max_y, pos.y)
        
    min_x = min_x * Globals.grid_size
    min_y = min_y * Globals.grid_size
    max_x = (max_x + 1) * Globals.grid_size # add one to get the rightmost side of tile
    max_y = (max_y + 1) * Globals.grid_size
    dimensions = Vector2(max_x - min_x, max_y - min_y)
    
func generate_obstacles_from_tiles():
    var dynamicMap = get_node("../DynamicTileMap")
    if not dynamicMap:
        return
    
    for pos in dynamicMap.get_used_cells():
        var tile = dynamicMap.get_cell(pos.x, pos.y)
        match tile:
            2:
                create_spike(pos, 0)
            3:
                create_spike(pos, deg2rad(-90))
            4:
                create_spike(pos, deg2rad(180))
            5:
                create_spike(pos, deg2rad(90))
            _:
                assert(false, "Could not create dynamic tile #" + str(tile))
    
func create_spike(pos: Vector2, rot: float) -> void:
    var obstacle = spike_scene.instance()
    obstacle.set_position(pos * Globals.grid_size + (Vector2.ONE * Globals.half_grid_size))
    obstacle.set_rotation(rot)
    add_child(obstacle)

func spawn_player():
    var player = player_scene.instance()
    player.set_position(entrance.get_position())
    add_child(player)
