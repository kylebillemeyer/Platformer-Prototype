tool
extends Node2D

# Declare member variables here. Examples:
export var width = 1000
export var height = 500
export var entrance_pos = Vector2(100, 475)
export var exit_pos = Vector2(800, 455)
export var next_level_path = "res://levels/Level 1.tscn"

var next_level
var go_to_next_level
var go_to_reset_level
var exit_shape

# Called when the node enters the scene tree for the first time.
func _ready():
	var wall_scene = load("res://Wall.tscn")
	var floor_scene = load("res://StaticFloor.tscn")
	var player_scene = load("res://Player.tscn")
	next_level = load(next_level_path)
	
	var left_wall = wall_scene.instance()
	left_wall.set_scale(Vector2(1, height / 100.0))
	left_wall.set_position(Vector2(5, height / 2.0))
	add_child(left_wall)
	
	var right_wall = wall_scene.instance()
	right_wall.set_scale(Vector2(1, height / 100.0))
	right_wall.set_position(Vector2(width - 5, height / 2.0))
	add_child(right_wall)
	
	var ceiling = floor_scene.instance()
	ceiling.set_scale(Vector2(width / 100.0, 1))
	ceiling.set_position(Vector2(width / 2.0, 5))
	add_child(ceiling)
	
	var ground = floor_scene.instance()
	ground.set_scale(Vector2(width / 100.0, 1))
	ground.set_position(Vector2(width / 2.0, height - 5))
	add_child(ground)
	
	var player = player_scene.instance()
	player.set_position(entrance_pos)
	add_child(player)
	
	var exit = get_node("Exit")
	exit.set_position(exit_pos)
	exit_shape = get_node("Exit/CollisionShape2D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if go_to_next_level:	
		var root = get_tree().root
		var current_level = get_parent()
		root.remove_child(current_level)
		root.add_child(next_level.instance())
		
	if go_to_reset_level:
		get_parent().get_tree().reload_current_scene()
		
func reset_level():
	go_to_reset_level = true
		
func _draw():
	var extents = exit_shape.get_shape().get_extents()
	draw_rect(Rect2(exit_pos - extents, extents * 2), Color.gray, true)

func _on_level_exited(area):
	go_to_next_level = true
