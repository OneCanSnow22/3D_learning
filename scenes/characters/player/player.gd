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
@onready var camera: Camera3D = %Camera3D
var input_dir:=Vector2.ZERO
var normal_fov: float
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
func _ready() -> void:
	normal_fov=camera.fov
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
func check_jump_input():
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y=jump_force
func process_gravity():
	if not is_on_floor():
		velocity.y-=gravity
