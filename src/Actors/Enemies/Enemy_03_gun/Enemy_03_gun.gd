extends "res://src/Actors/Enemies/Enemy.gd"

const SCENE_ENEMYRGUN: = preload ("res://src/Objects/Projectiles/EnemyGun.tscn")

var shootDir = Vector2(1,0)
var shootingAngle
var targetBody

func _process(delta: float) -> void:
	if canShoot():
		if stats.health != 0:
			if AttackCooldownTim2.is_stopped():
				shootAttackImpulse(targetBody)


func update_direction():
	var idk = targetBody.global_position
	shootDir = self.global_position.direction_to(idk)
	shootingAngle = rad2deg(shootDir.angle())

func shoot_attack(projectl_direction):
	if SCENE_ENEMYRGUN:
		var enemygun = SCENE_ENEMYRGUN.instance()
		
		if shootingAngle <= -135 or shootingAngle >= 135: #Vlevo
			$BulletSpawner.position.x = -10
			$BulletSpawner.position.y = 2
#			print("leftShooting \n")
			
		elif shootingAngle <= 135 and shootingAngle >= 45: #Dolu
			$BulletSpawner.position.x = 0
			$BulletSpawner.position.y = 5
#			print("downShooting \n")
			
		elif shootingAngle <= 45 and shootingAngle >= -45: #Vpravo
			$BulletSpawner.position.x = 5
			$BulletSpawner.position.y = 2
#			print("rightShooting \n")
			
		elif shootingAngle >= -135 and shootingAngle <= -45: #Nahoru
			$BulletSpawner.position.x = 0
			$BulletSpawner.position.y = -6
#			print("upShooting \n")
		enemygun.transform = $BulletSpawner.global_transform
		
#		print("Shooting angle: " + str(shootingAngle))
		owner.call_deferred("add_child", enemygun) #deferred kvůli ňakýmu erroru
		
		var enemygun_rotation = projectl_direction.angle()
		enemygun.rotation = enemygun_rotation
		AttackCooldownTim.start()
		AttackCooldownTim2.start()

func canShoot():
	var can_shoot = false
	targetBody = Globals.player_node
	if targetBody:
		var EnemyToPlayer = targetBody.global_position - self.global_position #vector
		var facing = Vector2.RIGHT.rotated(_last_dir.angle())
		
		if EnemyToPlayer.length() < 180 and EnemyToPlayer.length() > 100:
			if EnemyToPlayer.normalized().dot(facing) > 0: #Pokud je hráč ve fov, může střílet 
				$CanShoot.cast_to = EnemyToPlayer
				if !$CanShoot.is_colliding():
					can_shoot = true
		elif EnemyToPlayer.length() <= 100: #I když je hráč mimo fov enemáka, může střílet
			$CanShoot.cast_to = EnemyToPlayer 
			if !$CanShoot.is_colliding(): #Když nekoliduje se světem
				can_shoot = true
	
	return can_shoot

func move_away_from_player():
	pass

func shootAttackImpulse(body):
	if AttackCooldownTim.is_stopped() and body != null:
		update_direction() #Aktualizace směru
		shoot_attack(shootDir)


#func _on_PlayerDetection_area_entered(area: Area2D) -> void:
#	targetBody = area
#	if AttackCooldownTim.is_stopped():
#		update_direction()
#		shoot_attack(shootDir)
#	if AttackCooldownTim2.is_stopped():
#		AttackCooldownTim2.start()
#
#
#func _on_PlayerDetection_area_exited(area: Area2D) -> void:
#	if area.is_in_group("player_hurtbox"):
#		targetBody = null
