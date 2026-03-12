extends CharacterBody2D

@onready var animator: Node2D = $PlayerAnimator
@onready var input_handler: Node = $PlayerInput
@onready var state_machine: Node = $StateMachine
@onready var hitbox: PlayerHitbox = $Hitbox
@onready var input_buffer: InputBuffer = $InputBuffer


# Physics stats
var movespeed = 400
var ground_friction = 1900 # skid power, lower value = longer slide
var jump_velocity = -600
var fastfall_velocity = 500
var dash_speed = 400
var air_dash_speed = 380
var air_accel = 1500
var air_max_speed = 400

# Frame stats
var land_frames = 5
var dash_frames = 10

var input_buffer_time = 0.2  # seconds
var input_buffer_timer = 0.0

var facing_direction = 1

func _physics_process(delta):
	input_buffer.capture_inputs(input_handler)

	input_buffer.update()
	#print("movespeed: ", velocity.x)
	if facing_direction < 0:
		hitbox.scale.x = -1
	else:
		hitbox.scale.x = 1
	move_and_slide()

func wait_frames(frames: int) -> void:
	for i in frames:
		await get_tree().physics_frame
