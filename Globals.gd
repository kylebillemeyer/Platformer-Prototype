extends Node

# In order to make level transitions a bit cleaner, this guard prevents the player 
# from moving for X seconds after the level begins processing.
var process_guard = .25 

var jump_height = 300
var jump_width = 300
var jump_and_return_time = .75

var player_extents = Vector2(25, 25)
var initial_jump_velocity
var gravity

func _ready():
	# Adding the half the player height so the jump height is 
	# calculated from the players feet
	initial_jump_velocity = 2 * (jump_height + player_extents.y) / (jump_and_return_time / 2.0)
	gravity = initial_jump_velocity / (jump_and_return_time / 2.0)