extends Area2D

#Aby fungovala detekce, musí u enemáka být ve skupině enemy_hurtbox, aby bcs u zbraní je if enemy.in_group enemy_hurtbox
#Je to useless, bcs layers, ale jistota jakoby

#Někde udělat hit sound
onready var invulnerabilityTimer = $Invulnerability
export(bool) var is_flying: bool = false

var was_trap_hit = false


func trap_hit() -> void: #pokud hituje trapka a zabije enemáka, aby hráč nedostal +kill a goldy
	was_trap_hit = true

func onHitBySmth(damage, knockback_dir): #přidělat sílu knockbacku
	damage(damage, knockback_dir)

func damage(amount, knockback_dir):
	if invulnerabilityTimer.is_stopped():
		invulnerabilityTimer.start()
		var staty = get_parent().stats
		
		if get_parent().name != "Player":
			if staty.health - amount <= 0: #menší nebo rovno bcs ještě nejsou clampnuté na 0
				if was_trap_hit:
					staty.is_killed_by_player = false
					was_trap_hit = false
			$Audio_hurt_enemy.play()
		elif get_parent().name == "Player":
			$Audio_hurt_player.play()
		
		staty._set_health(staty.health - amount)
		get_parent().onGotHitKnockback(knockback_dir) #Knockback při dostání hitu
		was_trap_hit = false

