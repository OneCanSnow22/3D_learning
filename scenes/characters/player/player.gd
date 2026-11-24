class_name Player
extends CharacterBody3D
const MAX_ANGLE_LOOK_UP:=deg_to_rad(70)
const MAX_ANGLE_LOOK_DOWN:=deg_to_rad(-70)
@export var mouse_sensitivity:float
@export var run_speed:float
@export var jump_force:float
@export var gravity:float
@export var walk_speed:float
@export var acceleration:float
@export var fov_transition_multiplier: float = 2.0
@export_category("Head Bob")
@export var walk_bob_frequency: float = 8.0
@export var walk_bob_amplitude: float = 0.045
@export var run_bob_frequency: float = 13.0
@export var run_bob_amplitude: float = 0.08
@export var bob_smoothness: float = 12.0
@export var bob_transition_speed: float = 7.0
@onready var camera: Camera3D = %Camera3D
var input_dir:=Vector2.ZERO
var normal_fov: float
var camera_base_position: Vector3
var head_bob_time: float = 0.0
var head_bob_strength: float = 0.0
var head_bob_run_blend: float = 0.0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
func _ready() -> void:
	normal_fov=camera.fov
	camera_base_position = camera.position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x*mouse_sensitivity)
		camera.rotate_x(-event.relative.y*mouse_sensitivity)
		camera.rotation.x=clampf(camera.rotation.x,MAX_ANGLE_LOOK_DOWN,MAX_ANGLE_LOOK_UP)
func _process(delta: float) -> void:
	input_dir=Input.get_vector("strafe_left","strafe_right","backward","forward")
	
	
func _physics_process(delta: float) -> void:
	check_jump_input()
	process_gravity()
	var input_3d_space:=Vector3(input_dir.x,0,-input_dir.y)
	var is_running: bool = Input.is_action_pressed("run")
	var target_speed:=run_speed if is_running else walk_speed
	var desired_velocity=transform.basis*input_3d_space*target_speed
	if input_3d_space==Vector3.ZERO:
		velocity.x=move_toward(velocity.x,0,acceleration*delta)
		velocity.z=move_toward(velocity.z,0,acceleration*delta)
	else:
		velocity.x=move_toward(velocity.x,desired_velocity.x,acceleration*delta)
		velocity.z=move_toward(velocity.z,desired_velocity.z,acceleration*delta)
	var target_fov: float = normal_fov +15 if is_running else normal_fov
	camera.fov=move_toward(camera.fov,target_fov,acceleration*fov_transition_multiplier*delta)
	move_and_slide()
	update_head_bob(delta, is_running)

func update_head_bob(delta: float, is_running: bool) -> void:
	var horizontal_speed: float = Vector2(velocity.x, velocity.z).length()
	var has_move_input: bool = input_dir.length() > 0.01
	var target_strength: float = 1.0 if is_on_floor() and has_move_input and horizontal_speed > 0.1 else 0.0
	var target_run_blend: float = 1.0 if target_strength > 0.0 and is_running else 0.0
	var target_position: Vector3 = camera_base_position

	head_bob_strength = move_toward(head_bob_strength, target_strength, bob_transition_speed * delta)
	head_bob_run_blend = move_toward(head_bob_run_blend, target_run_blend, bob_transition_speed * delta)

	if head_bob_strength > 0.001:
		var frequency: float = lerpf(walk_bob_frequency, run_bob_frequency, head_bob_run_blend)
		var amplitude: float = lerpf(walk_bob_amplitude, run_bob_amplitude, head_bob_run_blend) * head_bob_strength
		head_bob_time += delta * frequency
		target_position.y += sin(head_bob_time) * amplitude
		target_position.x += cos(head_bob_time * 0.5) * amplitude * 0.35

	var blend: float = 1.0 - exp(-bob_smoothness * delta)
	camera.position = camera.position.lerp(target_position, blend)
func check_jump_input():
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y=jump_force
func process_gravity():
	if not is_on_floor():
		velocity.y-=gravity
