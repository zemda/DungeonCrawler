extends Area2D

var heals = 7


func _on_HealPotion_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var staty = area.get_parent().stats
		if staty.hasMaxHealth():
			pass
		else:
			$Audio_heal.play()
			print("wut")
			number()
			staty._set_health(staty.health + heals)
			queue_free()
	#třeba přidat sound
	#při healu ukázat kolik +hp


func number():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	heals = rng.randi_range(7, 20)


