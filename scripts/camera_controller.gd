extends Camera3D

var paused = false
var mouse_camera_sensitivity = 0.005
var camera_zoom_sensitivity = 1
var camera_zoom_min = 1
var camera_zoom_max = 200

@onready var rot_hor = $"../.."
@onready var rot_ver = $".."

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		paused = not paused
		if paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if Input.is_action_just_pressed("zoom_in"):
		position.z = clamp(position.z - camera_zoom_sensitivity, camera_zoom_min, camera_zoom_max)
	if Input.is_action_just_pressed("zoom_out"):
		position.z = clamp(position.z + camera_zoom_sensitivity, camera_zoom_min, camera_zoom_max)

func _unhandled_input(event):
	if paused: return
	if event is InputEventMouseMotion:
		rot_hor.rotate_y(-event.relative.x * mouse_camera_sensitivity)
		rot_ver.rotate_x(-event.relative.y * mouse_camera_sensitivity)
		rot_ver.rotation.x = clamp(rot_ver.rotation.x, -PI/2, PI/2)

