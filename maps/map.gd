extends Node3D

@export var laps: int = 2

var checkpoints = {}
func _ready():
	var points: Array = get_tree().get_nodes_in_group("checkpoint")
	points.sort_custom( func(l, r): return l.number > r.number)
	var counter = 0
	for checkpoint in points:
		checkpoint.number = counter
		checkpoints[counter] = checkpoint
		counter += 1
		
func get_next_checkpoint(number: int):
	var next = (number + 1) % checkpoints.size()
	return checkpoints[next]
