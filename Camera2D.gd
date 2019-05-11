extends Camera2D

# Declare member variables here. Examples
export var max_translate_distance = 100
export var translate_speed = 1000

var o
var use_joystick

# Called when the node enters the scene tree for the first time.
func _ready():
	o = Vector2(0, 0)
	use_joystick = Input.is_joy_known(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera_pos = get_camera_screen_center()
	var player_pos = get_parent().get_global_position()
	var mouse_pos = get_global_mouse_position()
	
	var direction = Vector2(0, 0)
	if (use_joystick):
		if (Input.is_action_pressed("aim_up")):
			direction += Vector2(0, -1)
		elif (Input.is_action_pressed("aim_down")):
			direction += Vector2(0, 1)
		elif (camera_pos.y - player_pos.y > 10):
			direction += Vector2(0, -1)
		elif (player_pos.y - camera_pos.y > 10):
			direction += Vector2(0, 1)
			
		if (Input.is_action_pressed("aim_right")):
			direction += Vector2(1, 0)
		elif (Input.is_action_pressed("aim_left")):
			direction += Vector2(-1, 0)
		elif (camera_pos.x - player_pos.x > 10):
			direction += Vector2(-1, 0)
		elif (player_pos.x - camera_pos.x > 10):
			direction += Vector2(1, 0)
	
	set_offset((offset + direction * translate_speed * delta).clamped(max_translate_distance))
	#print_debug("mouse: " + str(mouse_pos) + "player: " + str(player) + ", dir: " + str(direction) + ", offset: " + str(offset))
