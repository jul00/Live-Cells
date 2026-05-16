extends Area2D

@export var speed: float = 400.0

func _physics_process(delta: float) -> void:
	# Move in the direction the arrow is actually pointing
	position += transform.x * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("receive_hit"):
		body.receive_hit(10.0, self)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
