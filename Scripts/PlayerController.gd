class_name PlayerController extends CharacterBody3D

@export var walk_speed: float = 6
@export var acceleration: float = 10
@export var gravity: float = 15
@export var mouse_sensitivity: float = 0.05
@export var jump_strength: float = 6
@export var joypad_sensitivity: float = 2
@export var joypad_deadzone: float = 0.15

@onready var camera := $Camera3D as Camera3D

var direction := Vector3()
var gravity_vec := Vector3()
var jumping: bool = false;


func _physics_process(delta: float) -> void:
	handle_movement_input()
	move(delta)


func handle_movement_input() -> void:
	direction = Vector3.ZERO
	if(Input.is_action_pressed("move_front")):
		direction += -transform.basis.z
	if(Input.is_action_pressed("move_back")):
		direction += transform.basis.z
	if(Input.is_action_pressed("move_left")):
		direction += -transform.basis.x
	if(Input.is_action_pressed("move_right")):
		direction += transform.basis.x
	direction = direction.normalized()
	
	jumping = Input.is_action_just_pressed("jump")
	

func move(delta: float) -> void:
	velocity = velocity.lerp(direction * walk_speed, acceleration * delta)
	
	if is_on_floor():
		velocity.y = 0
		gravity_vec = Vector3()
		if jumping:
			gravity_vec.y = jump_strength
	else:
		gravity_vec += Vector3.DOWN * gravity * delta
	
	velocity.y = gravity_vec.y
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var mouse_event := event as InputEventMouseMotion
		rotate_y(deg_to_rad((-mouse_event.relative.x * mouse_sensitivity)))
		camera.rotate_x(deg_to_rad(-mouse_event.relative.y * mouse_sensitivity))
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
