extends "res://src/Actors/Enemies_2gen/Enemy_2gen.gd"

const SCENE_ENEMYRGUN: = preload ("res://src/Objects/Projectiles/EnemyGun.tscn")

var shootDir = Vector2(1,0)
var shootingAngle
var targetBody

func _physics_process(delta: float) -> void:
	
	match state:
		CHASE:
			if Globals.player_node:
				var EnemyToPlayer_distance = (player.global_position - self.global_position).length() #EP = P-E
				
				if EnemyToPlayer_distance > 80:
					generate_path()
					navigate()
				elif EnemyToPlayer_distance <= 80 and EnemyToPlayer_distance >= 55:
#					motion = Vector2.ZERO
					if !$RayCast_can_see_player.is_colliding():
						motion = motion.move_toward(Vector2.ZERO, 200 * delta)
					else:
						generate_path()
						navigate()
				elif EnemyToPlayer_distance < 55: #pokud je tak daleko od hrace, jde dal od nej
					if !$RayCast_can_see_player.is_colliding():
						generate_path_to_move_away()
						navigate()
#						var dir = (position.direction_to(player.global_position))
##						motion += -dir * ACCELERATION
#						motion = motion.move_toward(-dir * speed * 1.2, ACCELERATION * delta)


func _process(delta: float) -> void:
	if canShoot():
		if stats.health != 0:
			if AttackCooldownTim2.is_stopped():
				shootAttackImpulse(targetBody)


func generate_path_to_move_away():
	var _dir = (global_position - player.global_position).normalized()
	path = navigation.get_simple_path(global_position, global_position + _dir * 40, false)


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
		
		owner.call_deferred("add_child", enemygun) #deferred kvůli ňakýmu erroru
#		owner.add_child(enemygun)
		
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
				$RayCast_can_see_player.cast_to = EnemyToPlayer
				if !$RayCast_can_see_player.is_colliding():
					can_shoot = true
		elif EnemyToPlayer.length() <= 100: #I když je hráč mimo fov enemáka, může střílet
			$RayCast_can_see_player.cast_to = EnemyToPlayer 
			if !$RayCast_can_see_player.is_colliding(): #Když nekoliduje se světem
				can_shoot = true
	
	return can_shoot


func shootAttackImpulse(body):
	if AttackCooldownTim.is_stopped() and body != null:
		update_direction() #Aktualizace směru
		$RayCast_can_see_player.cast_to = player.global_position - self.global_position
		if !$RayCast_can_see_player.is_colliding(): #první shot tohle nějak bypassuje
			shoot_attack(shootDir)
