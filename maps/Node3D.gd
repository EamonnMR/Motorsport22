extends VehicleBody3D

@export var movement_speed: float = 4.0
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
var movement_delta: float

var max_engine_force = 100
var max_steering = PI/5

var min_steering = 0.1

var manual_control = true

var STEERING_RATE = 1.0

func set_limited_steering(new_steering, delta):
	var adjusted_steering = clamp(new_steering, -1 * max_steering, max_steering)
	var steer = steering
	var lerp_factor = STEERING_RATE * delta
	steering = lerp(
		steer * 1.0,
		adjusted_steering * 1.0,
		0.1
	)
	#if abs(steering) < min_steering:
	#	steering = 0
	

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	$PathMarker.hide()
	
	if Input.is_action_just_pressed("toggle_control_mode"):
		manual_control = not manual_control
	
	if manual_control:
		_physics_process_manual(delta)
	else:
		_physics_process_ai(delta)
	$Label3D.text = "Steering: " + str(steering) + "\nBrake: " + str(brake) + "\nEngine Force: " + str(engine_force)
		
	
func _physics_process_manual(delta):
	if Input.is_action_pressed("steer_left"):
		set_limited_steering(max_steering, delta)
	elif Input.is_action_pressed("steer_right"):
		set_limited_steering(max_steering * -1, delta)
	else:
		set_limited_steering(0, delta)
	
	if Input.is_action_pressed("throttle"):
		engine_force = max_engine_force
	elif Input.is_action_pressed("reverse"):
		engine_force = -max_engine_force
	else:
		engine_force = 0
		
	if Input.is_action_pressed("brake"):
		brake = max_engine_force
	else:
		brake = 0

func _physics_process_ai(delta):
	
	if Input.is_action_just_pressed("brake"):
		var checkpoint = get_tree().get_nodes_in_group("checkpoint")[0]
		set_movement_target(checkpoint.global_transform.origin)
	
	if navigation_agent.is_navigation_finished():
		return

	movement_delta = movement_speed * delta
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var current_agent_position: Vector3 = global_position
	
	# var facing = global_transform.basis.get_rotation_quaternion().get_euler().y
	
	var localized_path_position = to_local(next_path_position)
	
	var euler = Transform3D.IDENTITY.looking_at(
		localized_path_position, Vector3.UP
	).basis.get_euler()
	
	#$Label3D.text = "euler looking at point: \nX: " + str(euler.x) + "\nY: " + str(euler.y) + "\nZ: " + str(euler.z) + "\n"
	set_limited_steering(-1 * euler.y, delta)
	
	engine_force = max_engine_force
	
	brake = 0
	#TODO: Steer towards next path position, increase engine power if facing the right way, otherwise
	# keep it lower.
