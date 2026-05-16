extends Area2D

@export var speed: float = 400.0
@export var rotation_speed: float = 20.0
@export var damage: float = 5.0

@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	# Move horizontally in the direction of transform.x
	position += transform.x * speed * delta
	
	# Spin the shuriken
	sprite.rotation += rotation_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("receive_hit"):
		body.receive_hit(damage, self)
	
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
