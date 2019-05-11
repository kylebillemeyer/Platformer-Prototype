extends Camera2D

# Declare member variables here. Examples
export var max_translate_distance = 100
export var translate_speed = 10

var o
var use_joystick
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	o = Vector2(0, 0)
	use_joystick = Input.is_joy_known(0)
	screen_size = get_viewport_rect().size
	max_translate_distance = screen_size.y * .5 *.75

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera_pos = get_camera_screen_center()
	var player_pos = get_parent().get_global_position()
	var mouse_pos = get_global_mouse_position()
	
	if (use_joystick):
		var destination = max_translate_distance * Vector2(thresh(Input.get_joy_axis(0, JOY_AXIS_2)), thresh(Input.get_joy_axis(0, JOY_AXIS_3)))
		var direction = destination - offset
		
		#print_debug("dest: " + str(destination) + ", dir: " + str(direction))
	
		set_offset(offset + direction * translate_speed * delta)
		
func thresh(f) -> float:
	if f < .1 && f > -.1:
		return 0.0
	else:
		return f

func _on_Timer_timeout():
	print_debug(
		str(max_translate_distance * Vector2(thresh(Input.get_joy_axis(0, JOY_AXIS_2)), thresh(Input.get_joy_axis(0, JOY_AXIS_3)))) + ", " + 
		str(Input.get_joy_axis(0, JOY_AXIS_2)) + ", " + 
		str(Input.get_joy_axis(0, JOY_AXIS_3)))
