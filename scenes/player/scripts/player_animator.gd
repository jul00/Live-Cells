extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func play_idle():
	animated_sprite.play("Idle")

func play_run():
	animated_sprite.play("Running")
	
func play_skid():
	animated_sprite.play("Skid")
	
func play_dash():
	animated_sprite.play("Dashing")

func play_jump():
	animated_sprite.play("Jumping")

func play_fall():
	animated_sprite.play("Falling")
	
func play_land():
	animated_sprite.play("Land")

func play_norm1():
	animated_sprite.play("GroundNeutralN1")

func play_norm2():
	animated_sprite.play("GroundNeutralN2")

func play_norm3():
	animated_sprite.play("GroundNeutralN3")

func play_up_norm():
	animated_sprite.play("GroundUpN")

func play_air_norm():
	animated_sprite.play("AirNeutralN")

func play_neutral_special():
	animated_sprite.play("NeutralSpecial")

func set_facing(direction: float):
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

func get_sprite():
	return animated_sprite
