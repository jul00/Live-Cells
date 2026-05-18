extends CPUParticles2D

func _ready() -> void:
	emitting = true
	if not finished.is_connected(queue_free):
		finished.connect(queue_free)
