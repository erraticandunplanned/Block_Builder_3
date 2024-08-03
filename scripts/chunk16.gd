extends Node3D

var single_block = preload("res://scenes/single_block_chunk.tscn")
var chunksize = Vector3(8,8,8)
var threadlist = {}

@onready var block_container = $block_container

## CALLED FROM MAIN.GD ONCE THE CHUNK IS PLACED IN THE WORLD
## CREATES A CUBE OF [CHUNKSIZE] SIZE, AND THEN STARTS A THREAD TO GENERATE EACH BLOCK
func generate_chunk_from_seed(seed : FastNoiseLite, chunk_loc : Vector3):
	for i in chunksize.x:
		for j in chunksize.y:
			for k in chunksize.z:
				var block_location = Vector3(i,j,k)
				var thread = Thread.new()
				var global_block_location = chunk_loc + block_location
				threadlist[global_block_location] = thread
				thread.start(thread_generate_block.bind(global_block_location,block_location,seed))

## CHECKS THE NOISEMAP, IF IT IS A VALID BLOCK, INSTANTIATE A BLOCK SCENE AND NAME IT
func thread_generate_block(glob_loc, loc, seed):
	if seed.get_noise_3d(glob_loc.x,glob_loc.y,glob_loc.z) > 0:
		call_deferred("cancel_thread", glob_loc)
	else:
		var newblock = single_block.instantiate()
		newblock.name = str(glob_loc)
		call_deferred("thread_finish_block", newblock, glob_loc)

## ADDS BLOCK TO SCENE TREE AND POSITIONS IT
func thread_finish_block(block, loc):
	block_container.add_child(block)
	block.global_position = loc
	cancel_thread(loc)

func cancel_thread(loc):
	var thread = threadlist.get(loc)
	if thread.is_alive():
		thread.wait_to_finish()

func _exit_tree():
	for i in threadlist.values():
		i.wait_to_finish()
