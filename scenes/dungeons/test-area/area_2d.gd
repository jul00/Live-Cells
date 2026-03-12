extends Area2D
class_name EnemyHurtbox

var health = 100

func take_damage(amount: int) -> void:
	health -= amount
	print("Hurtbox hit! Health:", health)
