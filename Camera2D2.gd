extends Camera2D

# Declare member variables here. Examples
export var max_translate_distance = 100
export var translate_speed = 1000
export var limit_buffer = 100

var o
var use_joystick

# Called when the node enters the scene tree for the first time.
func _ready():
	o = Vector2(0, 0)
	use_joystick = Input.is_joy_known(0)
	
	# This assume parent structure of /room/player/camera
	var room = find_parent("Room")
	var room_x = room.get_global_position().x
	var room_y = room.get_global_position().y - room.height
	var room_center_x = room_x + room.width / 2
	var room_center_y = room_y + room.height / 2
	
	var viewport_size = get_viewport().size
	
	var desired_limit_width = (room.width + limit_buffer * 2)
	var desired_limit_height = (room.height + limit_buffer * 2)
	
	if ((viewport_size.x * zoom.x) > desired_limit_width):
		var extent = viewport_size.x * zoom.x / 2
		limit_left = room_center_x - extent
		limit_right = room_center_x + extent
	else:
		limit_left = room_x - (limit_buffer / zoom.x)
		limit_right = room_x + room.width + (limit_buffer / zoom.x)
	
	if ((viewport_size.y * zoom.y) > desired_limit_height):
		var extent = viewport_size.y * zoom.y / 2
		limit_top = room_center_y - extent
		limit_bottom = room_y + extent
	else:
		limit_top = room_y - (limit_buffer / zoom.y)
		limit_bottom = room_y + room.height + (limit_buffer / zoom.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera_pos = get_camera_screen_center()
	var player_pos = get_parent().get_global_position()
	var mouse_pos = get_global_mouse_position()
		
	if (use_joystick):
		var destination = max_translate_distance * Vector2(thresh(Input.get_joy_axis(0, JOY_AXIS_2)), thresh(Input.get_joy_axis(0, JOY_AXIS_3)))
		var direction = destination - offset
		
		print_debug("dest: " + str(destination) + ", dir: " + str(direction))
	
		#set_offset(offset + direction * translate_speed * delta)
		
func thresh(f):
	if f < .1:
		0
	else:
		f