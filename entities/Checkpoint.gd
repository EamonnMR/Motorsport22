extends Area3D

@export var number: int

func _on_body_entered(body):
	if body.has_method("checkpoint_reached"):
		body.checkpoint_reached(number)
