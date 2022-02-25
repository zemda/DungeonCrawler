extends "res://src/Actors/Enemies_2gen/Enemy_2gen.gd"

const SCENE_WEAPON: = preload("res://src/Objects/Weapons/SwordEnemy.tscn")


func _physics_process(delta: float) -> void:
	match state:
		CHASE:
			if Globals.player_node:
				var EnemyToPlayer_distance = (player.global_position - self.global_position).length() #EP = P-E
				if EnemyToPlayer_distance > 60: #je daleko, jde k hráči
					generate_path()
					navigate()
				elif EnemyToPlayer_distance <= 60 and EnemyToPlayer_distance >= 30 and not AttackCooldownTim.is_stopped():#je blíž, ale už zaútočil a čeká
					motion = motion.move_toward(Vector2.ZERO, 200 * delta)
				elif EnemyToPlayer_distance <= 60 and EnemyToPlayer_distance >= 30 and AttackCooldownTim.is_stopped():#je blíž a jde útočit
					generate_path()
					navigate()

				elif EnemyToPlayer_distance < 30: #ej blízko, útočí a po útoku rychle počká a jde pryč
					var EnemyToPlayer = player.global_position - self.global_position
					$RayCast_can_see_player.cast_to = EnemyToPlayer
					if AttackCooldownTim.is_stopped():
						generate_path()
						navigate()
					else:
						var temp_tim = Timer.new()
						add_child(temp_tim)
						temp_tim.start(0.3)
						yield(temp_tim, "timeout")
						if Globals.player_node: #bcs hráč může umřít počas yieldu
							var dir = (position.direction_to(player.global_position))
#							motion += -dir * ACCELERATION
							motion = motion.move_toward(-dir * speed * 1.2, ACCELERATION * delta)


func _attack():
	var weapon: = SCENE_WEAPON.instance()
	weapon.add_to_group("weapons")
	
	#Mby ve vylepšené verzi enemáka s mečem tak mu udělat i šikmou rotaci meče, tzn 8-direction
	if attack_angle <= -135 or attack_angle >= 135: #Vlevo
		weapon.rot = -90
		weapon.position.x = -5
		weapon.position.y = 2
#		print("leftAttack")

	elif attack_angle <= 135 and attack_angle >= 45: #Dolu
		weapon.rot = 180
		weapon.position.x = 0
		weapon.position.y = 5
#		print("downAttack")

	elif attack_angle <= 45 and attack_angle >= -45: #Vpravo
		weapon.rot = 90
		weapon.position.x = 5
		weapon.position.y = 2
#		print("rightAttack")

	elif attack_angle >= -135 and attack_angle <= -45: #Nahoru
		weapon.rot = 0
		weapon.position.x = 0
		weapon.position.y = -8
#		print("upAttack")
#	if attack_angle <= -157.5 or attack_angle >= 157.5: #Vlevo
#		weapon.rot = -90
#		weapon.position.x = -5
#		weapon.position.y = 2
#		print("leftAttack")
#
#	elif attack_angle <= 157.5 and attack_angle >= 112.5: #šikmo vlevo dolů
#		weapon.rot = -67.5
#		weapon.position.x = -5
#		weapon.position.y = 3
#		print("leftDownAttack")
#
#	elif attack_angle <= 112.5 and attack_angle >= 67.5: #Dolu
#		weapon.rot = 180
#		weapon.position.x = 0
#		weapon.position.y = 5
#		print("downAttack")
#
#	elif attack_angle <= 67.5 and attack_angle >= 22.5: #šikmo vpravo dolů
#		weapon.rot = 157.5
#		weapon.position.x = 1
#		weapon.position.y = 6
#		print("rightDownAttack")
#
#	elif attack_angle <= 22.5 and attack_angle >= -22.5: #Vpravo
#		weapon.rot = 90
#		weapon.position.x = 5
#		weapon.position.y = 2
#		print("rightAttack")
#
#	elif attack_angle <= -22.5 and attack_angle >= -67.5: #šikmo vpravo nahoru
#		weapon.rot = 67.5
#		weapon.position.x = 1
#		weapon.position.y = -9
#		print("rightUpAttack")
#
#	elif attack_angle <= -67.5 and attack_angle >= -112.5: #Nahoru
#		weapon.rot = 0
#		weapon.position.x = 0
#		weapon.position.y = -8
#		print("upAttack")
#
#	elif attack_angle <= -112.5 and attack_angle <= -157.5: #šikmo vlevo nahoru 
#		weapon.rot = -22.5
#		weapon.position.x = -1
#		weapon.position.y = -9
#		print("leftUpAttack")

	#JEŠTĚ UPRAVIT ÚHLY A POZICE
	print("Attacking angle: " + str(attack_angle) + "\n")
	
	call_deferred("add_child", weapon) #Kvůli jakémusi erroru
	AttackCooldownTim.start()


func _on_Sword_impulse_area_entered(area: Area2D) -> void:
	if AttackCooldownTim.is_stopped():
		if stats.health != 0:
			_attack()

