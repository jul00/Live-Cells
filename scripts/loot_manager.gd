extends Node

@export var drop_chance: float = 0.2

const HEALTH_ITEM_SCENE = preload("res://scenes/health_items.tscn")

var loot_table = {
	"apple": {"anim": "apple", "value": 15.0},
	"bread": {"anim": "bread", "value": 10.0},
	"carrot": {"anim": "carrot", "value": 10.0},
	"cherry": {"anim": "cherry", "value": 15.0},
	"grapes": {"anim": "grapes", "value": 15.0},
	"maki": {"anim": "maki", "value": 20.0},
	"mango": {"anim": "mango", "value": 15.0},
	"melon": {"anim": "melon", "value": 15.0},
	"onigiri": {"anim": "onigiri", "value": 20.0},
	"ribs": {"anim": "ribs", "value": 30.0},
	"shrimp": {"anim": "shrimp", "value": 20.0},
	"steak": {"anim": "steak", "value": 30.0},
	"strawberry": {"anim": "strawberry", "value": 10.0},
	"sushi": {"anim": "sushi", "value": 20.0},
	"poo": {"anim": "poo", "value": -20.0}
}

func trigger_hit_stop(duration: float):
	Engine.time_scale = 0.05
	get_tree().create_timer(duration, true, false, true).timeout.connect(func():
		Engine.time_scale = 1.0
	)

func spawn_loot(pos: Vector2) -> void:
	if randf() > drop_chance:
		return
	
	var item = HEALTH_ITEM_SCENE.instantiate()
	add_child(item)
	item.global_position = pos
	
	var am = get_node_or_null("/root/AudioManager")
	if am:
		am.play_sfx("item_spawn")
	
	var item_name = loot_table.keys().pick_random()
	var data = loot_table[item_name]
	
	if item.has_method("setup"):
		item.setup(data["anim"], data["value"])
	else:
		push_error("Loot item does not have a setup method!")
