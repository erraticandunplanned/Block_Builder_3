extends Node3D

var import_chunk = preload("res://scenes/single_block_chunk.tscn")
var chunksize = Vector3(1,1,1)
var noisemap

var chunklist = {}
var threadlist = {}

@onready var block_container = $block_container

func _ready():
	noisemap = FastNoiseLite.new()
	noisemap.seed = randi()
	noisemap.noise_type = FastNoiseLite.TYPE_SIMPLEX
	generate_chunk_cube_at(0,0,0,25)

func _process(_delta):
	pass

## This function take an origin position and generates a cube of cubes of a specified side length 
## (side_length = 3 results in a 3x3 cube)
## each cube is offset by chunk_size
func generate_chunk_cube_at(x,y,z,side_length):
	for i in side_length:
		for j in side_length:
			for k in side_length:
				var newcoordinate = Vector3(x+(i*chunksize.x)-(side_length*chunksize.x/2), y+(j*chunksize.y)-(side_length*chunksize.y/2), z+(k*chunksize.z)-(side_length*chunksize.z/2))
				var thread = Thread.new()
				threadlist[newcoordinate] = thread
				thread.start(thread_generate_chunk.bind(newcoordinate))

### THREAD SHENANIGANS

func thread_generate_chunk(loc : Vector3):
	if noisemap.get_noise_3d(loc.x,loc.y,loc.z) > 0:
		call_deferred("cancel_thread", loc)
	else:
		var newchunk = import_chunk.instantiate()
		newchunk.global_position = loc
		newchunk.name = str(loc)
		call_deferred("thread_finish_chunk", newchunk, loc)

func cancel_thread(loc):
	var thread = threadlist.get(loc)
	if thread.is_alive():
		thread.wait_to_finish()

func thread_finish_chunk(chunk, loc : Vector3):
	block_container.add_child(chunk)
	cancel_thread(loc)
