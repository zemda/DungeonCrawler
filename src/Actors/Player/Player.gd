extends KinematicBody2D

export var max_speed = 150

onready var AttackCooldownTim = $AttackCooldown
onready var stats = $PlayerStats

const SCENE_WEAPON_SWORD: = preload("res://src/Objects/Weapons/SwordPlayer.tscn")
const SCENE_WEAPON_HAMMER: = preload("res://src/Objects/Weapons/Weapon_hammer.tscn")
const SCENE_WEAPON_SPEAR: = preload("res://src/Objects/Weapons/Weapon_spear.tscn")

const SCENE_PLAYERGUN: = preload ("res://src/Objects/Projectiles/PlayerGun.tscn")

var acceleration = 400 #Zrychlení
var friction = 150 #Zpomalení, mby ještě upravit
var knockback = Vector2.ZERO
var motion: = Vector2.ZERO

#Minulý směr, x1, neboli náš sprite je defaultně vpravo na x
var _last_dir: = Vector2(1.0, 0.0)
var _attack_dir: = Vector2(1.0, 0.0)

func _ready() -> void:
	Globals.player_node = self



#The _physics_process() runs at a fixed rate that doesn't change, by default it runs at 60 times a second.
#The _process() would run every single frame, so the amount of times it's called can change every second.
func _physics_process(delta: float) -> void:
#	var direction = _get_direction()
	knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
	knockback = move_and_slide(knockback)

	
	#-------------Novej item/inventory systém--------------#
	
	match PlayerStats.active_item:
		"Empty":
			pass #Nic nevykonávat, neboť hráč nic nedrží
		"Sword":
			if Input.get_action_strength("keyboard_attack") and AttackCooldownTim.is_stopped():
				AttackCooldownTim.set_wait_time(0.4)
				_melee_attack()
		"bow":
			if Input.get_action_strength("keyboard_attack") and AttackCooldownTim.is_stopped():
				var projectl_direction = self.global_position.direction_to(shooting_direction())
				shoot_attack(projectl_direction)
		"Health_potion":
			if Input.is_action_just_pressed("use_item"):
				if !stats.hasMaxHealth():
					$Audio_heal.play()
					stats._set_health(stats.health + 10) #+10 hp
					PlayerStats.remove_used_item()
		"hammer":
			if Input.get_action_strength("keyboard_attack") and AttackCooldownTim.is_stopped():
				AttackCooldownTim.set_wait_time(0.8)
				_melee_attack()
		"spear":
			if Input.get_action_strength("keyboard_attack") and AttackCooldownTim.is_stopped():
				AttackCooldownTim.set_wait_time(0.6)
				_melee_attack()
	
	#-------------Novej item/inventory systém--------------#
	func_move()


func func_move() -> void:
	var new_dir = Vector2(
		#Left = Vector2(-1,0), Right = Vector2(1,0)
		#Up = Vector2(0,-1), Down = Vector2(0,1) 
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
	new_dir = new_dir.normalized()
	#Pokud se pohneme, tak se aktualizuji promenne
	if new_dir != Vector2.ZERO:
		_last_dir = new_dir
		_attack_dir = new_dir
	
	if new_dir != Vector2.ZERO:
		motion += new_dir * acceleration
		motion = motion.clamped(max_speed)
		$Sprite.play("run2")
	else:
		motion = motion.move_toward(Vector2.ZERO, friction)
		$Sprite.play("idle2")
	
	$Sprite.flip_h = true if _last_dir.x < 0 else false
	motion = move_and_slide(motion)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pick_up"):
		if $PickUpArea.items_in_range.size() > 0:
			var pickup_item = $PickUpArea.items_in_range.values()[0]
			pickup_item.pick_up_item(self) #funkce z pickup_item_area.gd, kterou má pickable item
			var is_item_picked = pickup_item.is_picked_up()
			if is_item_picked:
				$PickUpArea.items_in_range.erase(pickup_item) #smazat z items_in_range dictionary, POKUD JEJ VEZMU
			#Nejbližší item se vezme
	if Input.is_action_just_pressed("jump"):
		if Globals.can_jump:
			jump()


func _melee_attack(): #Sword attack
	var weapon
	if PlayerStats.active_item == "Sword":
		weapon = SCENE_WEAPON_SWORD.instance()
	elif PlayerStats.active_item == "hammer":
		weapon = SCENE_WEAPON_HAMMER.instance()
	elif PlayerStats.active_item == "spear":
		weapon = SCENE_WEAPON_SPEAR.instance()
	
	weapon.add_to_group("weapons")
	if _attack_dir.x > 0: #Vpravo
		weapon.rot = 90
		weapon.position.x = 5
		weapon.position.y = 0
	elif _attack_dir.x < 0: #Vlevo
		weapon.rot = -90
		weapon.position.x = -5
		weapon.position.y = 0
	elif _attack_dir.y > 0: #Dolu
		weapon.rot = 180
		weapon.position.x = 0
		weapon.position.y = 3
		weapon.z_index = 1
	elif _attack_dir.y < 0: #Nahoru
		weapon.rot = 0
		weapon.position.x = 0
		weapon.position.y = -3

	add_child(weapon)
	AttackCooldownTim.start()


func shoot_attack(projectl_direction):
	if SCENE_PLAYERGUN:
		var playergun = SCENE_PLAYERGUN.instance()
		
		if _attack_dir.x > 0: #Vpravo
			$BulletSpawner.position.x = 3
			$BulletSpawner.position.y = -10
		elif _attack_dir.x < 0: #Vlevo
			$BulletSpawner.position.x = -3
			$BulletSpawner.position.y = 6
		elif _attack_dir.y > 0: #Dolu
			$BulletSpawner.position.x = 8
			$BulletSpawner.position.y = 5
		elif _attack_dir.y < 0: #Nahoru
			$BulletSpawner.position.x = -7
			$BulletSpawner.position.y = -5
		playergun.transform = $BulletSpawner.global_transform #Nastavení pozice spawnu střely
		
		var playergun_rotation = projectl_direction.angle()
		playergun.rotation = playergun_rotation #otočení do daného směru, ukládá se do direction v playergun.gd
		owner.add_child(playergun)
		AttackCooldownTim.start()


func shooting_direction(): #Shooting direction
	#Left = Vector2(-1,0), Right = Vector2(1,0)
	#Up = Vector2(0,-1), Down = Vector2(0,1)
	#Mby někdy předělat na lepší, idk
	
	var idk = global_position
	
	if _last_dir.x == -1 and _last_dir.y == 0: #left
		idk.x -= 100
	elif _last_dir.x == 1 and _last_dir.y == 0: #right
		idk.x += 100
	elif _last_dir.x == 0 and _last_dir.y == -1: #up
		idk.y -= 100
	elif _last_dir.x == 0 and _last_dir.y == 1: #down
		idk.y += 100
	
	#Spodní proměnné zajišťují šikmou střelu, tzn 8 dir, bez nich 4 dir
	elif Input.get_action_strength("move_left") and Input.get_action_strength("move_down"): #left down
		idk.x -= 100
		idk.y += 100
	elif Input.get_action_strength("move_right") and Input.get_action_strength("move_down"): #right down
		idk.x += 100
		idk.y += 100
	elif Input.get_action_strength("move_right") and Input.get_action_strength("move_up"): #right up
		idk.x += 100
		idk.y -= 100
	elif Input.get_action_strength("move_left") and Input.get_action_strength("move_up"): #left up
		idk.x -= 100
		idk.y -= 100
	
	
	return idk


func onGotHitKnockback(knockback_direction) -> void:
	knockback = knockback_direction * 75

func jump():
	max_speed = 300
	motion = motion * 8
	modulate.a = 0.5
	var tim = Timer.new()
	add_child(tim)
	tim.start(0.3)
	yield(tim, "timeout")
	max_speed = 150
	modulate.a = 1
