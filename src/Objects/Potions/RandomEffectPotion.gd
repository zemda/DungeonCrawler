extends Area2D

enum { #Ještě max health, až půjde setegt bez erroru
	HEALS,
	DEALS_DMG,
	ADDS_SPEED,
	REDUCES_SPEED
}

var effect := HEALS

var heals := 1
var dmg := 1
var a_speed := 1
var r_speed := 1


func _on_RandomEffectPotion_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		effect = numb_gen(0, 3)
		$Audio_heal.play()
		match effect:
			HEALS:
				heals = numb_gen(5, 15)
				var staty = area.get_parent().stats
				if staty.hasMaxHealth():
					staty._set_health(staty.health - heals) #takže deals_dmg
					queue_free()
				else:
					staty._set_health(staty.health + heals)
					queue_free()
	
			DEALS_DMG:
				dmg = numb_gen(5, 15)
				var staty = area.get_parent().stats
				staty._set_health(staty.health - dmg)
				queue_free()
	
			ADDS_SPEED:
				a_speed = numb_gen(5,  12)
				area.get_parent().max_speed += a_speed
				queue_free()
	
			REDUCES_SPEED:
				r_speed = numb_gen(5, 15)
				area.get_parent().max_speed -= r_speed
				queue_free()
	
		

func numb_gen(min_, max_):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var variable = rng.randi_range(min_, max_)
	return variable

