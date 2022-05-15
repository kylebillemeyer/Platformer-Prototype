tool
extends Node2D

export(int) var qunits_x = 1 setget set_qunits_x
export(int) var qunits_y = 1 setget set_qunits_y

export(bool) var spikes_on_top = false setget set_spikes_on_top
export(bool) var spikes_on_right = false setget set_spikes_on_right
export(bool) var spikes_on_bottom = false setget set_spikes_on_bottom
export(bool) var spikes_on_left = false setget set_spikes_on_left

var spikes_scn = preload("res://obstacles/BlockSpikes.tscn")
var block_scn = preload("res://obstacles/Block.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_block()
	
	if spikes_on_top:
		add_spikes(qunits_x, Vector2(0, -1), deg2rad(0))
	if spikes_on_right:
		add_spikes(qunits_y, Vector2(0, -qunits_x - 1), deg2rad(90))
	if spikes_on_bottom:
		add_spikes(qunits_x, Vector2(-qunits_x, -qunits_y - 1), deg2rad(180))
	if spikes_on_left:
		add_spikes(qunits_y, Vector2(-qunits_y, -1), deg2rad(270))
		
func add_block():
	var block = block_scn.instance()
	block.qunits_x = qunits_x
	block.qunits_y = qunits_y
	add_child(block)
	
func add_spikes(units, unit_translation, rotation):
	var t = Transform2D()
	t = t.rotated(rotation)
	t = t.translated(unit_translation * Globals.quarter_grid_size)
	
	var spikes = spikes_scn.instance()
	spikes.qunits_x = units
	spikes.set_transform(t)
	add_child(spikes)
	
func set_qunits_x(value: int) -> void:
	qunits_x = value
	reset()
	
func set_qunits_y(value: int) -> void:
	qunits_y = value
	reset()
	
func set_spikes_on_top(value: bool) -> void:
	spikes_on_top = value
	reset()
	
func set_spikes_on_right(value: bool) -> void:
	spikes_on_right = value
	reset()
	
func set_spikes_on_bottom(value: bool) -> void:
	spikes_on_bottom = value
	reset()
	
func set_spikes_on_left(value: bool) -> void:
	spikes_on_left = value
	reset()
	
func reset():
	for n in get_children():
		remove_child(n)
		n.queue_free()
	
	_ready()
