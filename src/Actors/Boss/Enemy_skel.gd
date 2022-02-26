extends KinematicBody2D

const SCENE_ENEMYRGUN: = preload ("res://src/Objects/Projectiles/EnemyGun.tscn")

onready var stats = $Stats
onready var animation_player = $AnimationPlayer
onready var navigation: Navigation2D = get_tree().get_root().get_node("Map").get_node("Navigation2D")
onready var player: KinematicBody2D = get_tree().get_root().get_node("Map").get_node("Player")
onready var AttackCooldownTim = $AttackCooldown
onready var AttackCooldownTim2 = $AttackCooldown2
onready var softColl = $SoftCollision


export var ACCELERATION = 300 #Zrychlení
export var FRICTION = 150 #Zpomalení

var knockback = Vector2.ZERO
var motion = Vector2.ZERO
var speed = 80 #wander speed
var dir = Vector2.ZERO #kvůli wander


var _last_dir: = Vector2(1.0, 0.0)
var _attack_dir: = Vector2(1.0, 0.0)

var attack_angle
var last_dir_angle 

var path: PoolVector2Array
var shootDir = Vector2(1,0)
var shootingAngle
var targetBody

func _ready() -> void:
	AttackCooldownTim.start()
	AttackCooldownTim2.start()

func _physics_process(delta: float) -> void:
	player = Globals.player_node
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	if stats.health == 0: knockback = Vector2.ZERO
	knockback = move_and_slide(knockback)
	
	
	
	if Globals.player_node:
		var EnemyToPlayer_distance = (player.global_position - self.global_position).length() #EP = P-E
		if EnemyToPlayer_distance > 120:
#			var direction = position.direction_to(Globals.player_node.global_position)
#			motion = motion.move_toward(direction * speed, ACCELERATION * delta)
			generate_path()
			navigate()
		elif EnemyToPlayer_distance <= 120 and EnemyToPlayer_distance >= 55:
			if !$RayCast_can_see_player.is_colliding():
				motion = motion.move_toward(Vector2.ZERO, 200 * delta)
				if canShoot():
					if stats.health != 0:
						if AttackCooldownTim2.is_stopped():
							shootAttackImpulse(targetBody)
			else:
#				var direction = position.direction_to(Globals.player_node.global_position)
#				motion = motion.move_toward(direction * speed, ACCELERATION * delta)
				generate_path()
				navigate()
		elif EnemyToPlayer_distance < 55: #pokud je tak daleko od hrace, jde dal od nej
#			var direction = position.direction_to(Globals.player_node.global_position)
#			motion = motion.move_toward(-direction * speed, ACCELERATION * delta)
			generate_path_to_move_away()
			navigate()

	
	
	if softColl.monitorable == true and softColl.monitoring == true:
		if softColl.is_colliding() and $softCollTimer.is_stopped():
			motion = softColl.push_vector() * 120
			$softCollTimer.start()
	if stats.health == 0: motion = Vector2.ZERO
	move()

func move() -> void:
	var new_dir = Vector2(motion)
	new_dir = new_dir.normalized()
	if new_dir != Vector2.ZERO: #Pokud se pohneme, tak se aktualizuji promenne
		_attack_dir = new_dir
		_last_dir = new_dir
		last_dir_angle = rad2deg(_last_dir.angle())
		attack_angle = rad2deg(_attack_dir.angle())
	
	
	motion = motion.clamped(80)
	motion = move_and_slide(motion)
	
	$AnimatedSprite.flip_h = motion.x < 0
	if motion != Vector2.ZERO:
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")


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


func shootAttackImpulse(body):
	if AttackCooldownTim.is_stopped() and body != null:
		update_direction() #Aktualizace směru
		shoot_attack(shootDir)
		

func navigate():
	if path.size() > 0: #pokud je cesta, tak pohyb na druhý bod
		var _dir = global_position.direction_to(path[1])
		motion += _dir * ACCELERATION
		if global_position == path[0]: #pokud jsme už došli, smazat ten bod z path
			path.remove(0)

func generate_path():
	if player:
		path = navigation.get_simple_path(global_position, player.global_position, false) #start pos, end pos, optimize


func onGotHitKnockback(knockback_dir) -> void: #Knockback při dostání hitu, přidat ještě knockback force
	knockback = (position.direction_to(Globals.player_node.global_position)) * (-1) * 140


func onHitKnockback(area) -> void: #Knockback při hitování hráče
	knockback = ((position.direction_to(area.global_position)) * (-1)) * 140 #random číslo, tak akorát

func canShoot():
	var can_shoot = false
	targetBody = Globals.player_node
	if targetBody:
		var EnemyToPlayer = targetBody.global_position - self.global_position #vector
		var facing = Vector2.RIGHT.rotated(_last_dir.angle())
		
		$RayCast_can_see_player.cast_to = EnemyToPlayer 
		if !$RayCast_can_see_player.is_colliding(): #Když nekoliduje se světem
			can_shoot = true
	
	return can_shoot
