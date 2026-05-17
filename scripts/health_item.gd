extends Area2D

@export var heal_amount: float = 0.0
@export var bob_speed: float = 0.5
@export var bob_amplitude: float = 5.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func setup(anim_name: String, value: float) -> void:
	heal_amount = value
	if sprite:
		sprite.play(anim_name)
	else:
		push_warning("HealthItem: AnimatedSprite2D child node not found.")

func _process(_delta: float) -> void:
	if sprite:
		sprite.position.y = -12 + sin(Time.get_ticks_msec() * 0.001 * bob_speed) * bob_amplitude

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("heal"):
		body.heal(heal_amount)
		queue_free()
