extends Area2D

@export var damage: int = 10

func _ready():
	add_to_group("player_attack")
