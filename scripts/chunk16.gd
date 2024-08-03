extends Node3D

var single_block = preload("res://scenes/single_block_chunk.tscn")
var chunksize = Vector3(8,8,8)
var threadlist = {}

@onready var block_container = $block_container

func generate_chunk_from_seed(seed : FastNoiseLite, chunk_loc : Vector3):
	for i in chunksize.x:
		for j in chunksize.y:
			for k in chunksize.z:
				var block_location = Vector3(i,j,k)
				var thread = Thread.new()
				var global_block_location = chunk_loc + block_location
				threadlist[global_block_location] = thread
				thread.start(thread_generate_block.bind(global_block_location,block_location,seed))

func thread_generate_block(glob_loc, loc, seed):
	if seed.get_noise_3d(glob_loc.x,glob_loc.y,glob_loc.z) > 0:
		call_deferred("cancel_thread", glob_loc)
	else:
		var newblock = single_block.instantiate()
		block_container.add_child(newblock)
		#block_container.call_deferred("add_child",newblock)
		newblock.global_position = loc
		newblock.name = str(glob_loc)
		call_deferred("thread_finish_block", newblock, glob_loc)

func cancel_thread(loc):
	var thread = threadlist.get(loc)
	if thread.is_alive():
		thread.wait_to_finish()

func thread_finish_block(block, loc):
	block_container.add_child(block)
	cancel_thread(loc)

func unload_self():
	pass

#func _exit_tree():
#	thread.wait_to_finish()
