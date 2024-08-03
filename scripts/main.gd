extends Node3D

var noisemap
var mapsize = Vector3(3,3,3)
var chunk_side_length = 8
var chunk_scene = preload("res://scenes/chunk16.tscn")
@onready var chunk_container = $chunk_container
@onready var HUD_text = $CanvasLayer/HUD/text/RichTextLabel
@onready var load_center = $load_center

var chunk_load_area = []

# Called when the node enters the scene tree for the first time.
func _ready():
	noisemap = FastNoiseLite.new()
	noisemap.seed = randi()
	noisemap.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	HUD_text.text = str(load_center.global_position)
	
	for x in mapsize.x:
		for y in mapsize.y:
			for z in mapsize.z:
				var new_location = Vector3(x * chunk_side_length , y * chunk_side_length ,z * chunk_side_length)
				var new_chunk = chunk_scene.instantiate()
				chunk_container.add_child(new_chunk)
				new_chunk.global_position = new_location
				new_chunk.name = str(new_location)
				new_chunk.generate_chunk_from_seed(noisemap, new_location)

func _process(delta):
	## MOVE THE LOCATION OF THE "LOAD CENTER" NODE ALONG X AND Y AXIS
	if Input.is_action_just_pressed("ui_up"):
		load_center.global_position += Vector3(0,chunk_side_length,0)
		HUD_text.text = str(load_center.global_position)
	if Input.is_action_just_pressed("ui_left"):
		load_center.global_position += Vector3(chunk_side_length,0,0)
		HUD_text.text = str(load_center.global_position)
	if Input.is_action_just_pressed("ui_down"):
		load_center.global_position -= Vector3(0,chunk_side_length,0)
		HUD_text.text = str(load_center.global_position)
	if Input.is_action_just_pressed("ui_right"):
		load_center.global_position -= Vector3(chunk_side_length,0,0)
		HUD_text.text = str(load_center.global_position)
	
	### FIND THE LOAD_AREA WHERE CHUNKS SHOULD BE LOADED
	## MAKE AN ARRAY OF VECTOR3 "LOAD_AREA"
	for i in mapsize.x:
		for j in mapsize.y:
			for k in mapsize.z:
				var check_location = load_center.global_position + Vector3( i * chunk_side_length , j * chunk_side_length , k * chunk_side_length )
				chunk_load_area.append(check_location)
	
	## COMPARE THE LOCATION OF EACH NODE IN CHUNK_CONTAINER TO EACH LOCATION IN LOAD_AREA.
	var existing_chunks = chunk_container.get_children()
	for chunk_to_test in existing_chunks:
		var to_be_deleted = true
		for location_to_test in chunk_load_area:
			if chunk_to_test.global_position == location_to_test:
				## IF A MATCH IS FOUND, THE CHUNK STAYS AS-IS. PREVENT IT FROM BEING DELETED AND REMOVE THE LOCATION FROM LOAD_AREA
				to_be_deleted = false
				chunk_load_area.remove_at(chunk_load_area.find(location_to_test))
		if to_be_deleted:
			## IF THE CHUNK'S LOCATION IS NOT IN THE LOAD_AREA, DELETE IT.
			chunk_to_test.unload_self()
	
	### LOAD ANY MISSING CHUNKS IN LOAD_AREA
	if chunk_load_area == []: return
	for new_location in chunk_load_area:
		var new_chunk = chunk_scene.instantiate()
		chunk_container.add_child(new_chunk)
		new_chunk.global_position = new_location
		new_chunk.name = str(new_location)
		new_chunk.generate_chunk_from_seed(noisemap, new_location)
	chunk_load_area.clear()
