extends Area2D
class_name PlayerHitbox

var hit_targets := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.area_entered.connect(on_area_entered)

func reset():
	hit_targets.clear()

func on_area_entered(area: Area2D) -> void:
	if area == null or not area is EnemyHurtbox:
		return
	
	if area in hit_targets:
		return
		
	print("Attack hit ", area.name)
	hit_targets.append(area)
