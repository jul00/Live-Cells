extends CharacterBody2D

@onready var animator = $PlayerAnimator
@onready var input_handler: Node = $PlayerInput
@onready var attack_handler: Node = $AttackHandler
@onready var state_machine: Node = $StateMachine

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
var dt_dash_window_frames = 6

var facing_direction = 1

func _physics_process(delta):
	#print("movespeed: ", velocity.x)
	move_and_slide()

func wait_frames(frames: int) -> void:
	for i in frames:
		await get_tree().physics_frame
