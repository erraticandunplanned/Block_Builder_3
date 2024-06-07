extends Node3D

var import_chunk = preload("res://scenes/single_block_chunk.tscn")
var chunksize = Vector3(1,1,1)

var chunklist = {}
var threadlist = {}

func _ready():
	generate_chunk_cube_at(0,0,0,3)

func _process(_delta):
	pass

func generate_chunk_cube_at(x,y,z,side_length):
	for i in side_length:
		for j in side_length:
			for k in side_length:
				var newcoordinate = Vector3(x+(i*chunksize.x)-(side_length*chunksize.x/2), y+(j*chunksize.y)-(side_length*chunksize.y/2), z+(k*chunksize.z)-(side_length*chunksize.z/2))
				var thread = Thread.new()
				threadlist[newcoordinate] = thread
				thread.start(thread_generate_chunk.bind(newcoordinate))

func thread_generate_chunk(loc : Vector3):
	var newchunk = import_chunk.instantiate()
	call_deferred("thread_finish_chunk", newchunk, loc)

func thread_finish_chunk(chunk, loc : Vector3):

	add_child(chunk)
	chunk.name = str(loc)
	chunk.global_position = loc
	var thread = threadlist.get(loc)
	if thread.is_alive():
		thread.wait_to_finish()
