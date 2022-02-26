extends KinematicBody2D

enum {
	IDLE,		#0
	WANDER,		#1
	CHASE,		#2
	RETURNING,	#3
}

onready var stats = $Stats
onready var animation_player = $AnimationPlayer
#onready var navigation: Navigation2D = get_tree().current_scene.get_node("Navigation2D")
#onready var player: KinematicBody2D = get_tree().current_scene.get_node("Player")
onready var navigation: Navigation2D = get_tree().get_root().get_node("Map").get_node("Navigation2D")
onready var player: KinematicBody2D = get_tree().get_root().get_node("Map").get_node("Player")
onready var AttackCooldownTim = $AttackCooldown


onready var AttackCooldownTim2 = $AttackCooldown2
onready var softColl = $SoftCollision
onready var state = IDLE setget state_setget
onready var spawning_position = self.global_position


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

func _ready() -> void:
	AttackCooldownTim.start()
	AttackCooldownTim2.start()

func _physics_process(delta: float) -> void:

	
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	if stats.health == 0: knockback = Vector2.ZERO
	knockback = move_and_slide(knockback)
	player = Globals.player_node
	match state:
		IDLE:
			motion = motion.move_toward(Vector2.ZERO, FRICTION * delta)
			can_chase()
			
			if !can_chase(): #je tam timer mezi switch state
				self.state = WANDER

		WANDER: #edit, wandering pouze v nějakém imaginárním boxu, nebo jít doprava, vrátit se na default spot nějak
			if $moveTimer.is_stopped():#každé 3s random směr
				$moveTimer.start()
				dir = choose_dir()
				motion = motion.move_toward(dir * 20, ACCELERATION * delta)
			motion = motion.move_toward(dir * speed, ACCELERATION * delta)
			
			$RayCast_Wander_coll.cast_to = _last_dir * 7 #raycast, pokud koliduje s něčím, tak tvolí nový směr
			if $RayCast_Wander_coll.is_colliding():
				dir = choose_dir()
				motion = motion.move_toward(dir * 20, ACCELERATION * delta)
			
			should_return()
			can_chase()
		
		CHASE:
			var direction = Vector2.ZERO
			if player:
				if not self.is_in_group("enemy_06_skeleton") and not self.is_in_group("enemy_07_sword"): #u těch je jiný match
					generate_path()
					navigate()
			
			if !can_chase():
				self.state = IDLE
		
		RETURNING: #vygeneruji path na cestu zpět, aby se nebugnul někde
			generate_path_for_return()
			navigate()
			can_chase()
			var vector_from_curr_to_spawn_pos = spawning_position - self.global_position
			if vector_from_curr_to_spawn_pos.length() < 20:
				self.state = IDLE
	
	if softColl.monitorable == true and softColl.monitoring == true:
		if softColl.is_colliding() and $softCollTimer.is_stopped():
			motion = softColl.push_vector() * 100
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
	
	if state == CHASE:
		motion = motion.clamped(100)
	else:
		motion = motion.clamped(50)
	motion = move_and_slide(motion)
	$AnimatedSprite.flip_h = motion.x < 0
	if motion != Vector2.ZERO:
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")
#	print(motion)
#	print(state)


func navigate():
	if path.size() > 0: #pokud je cesta, tak pohyb na druhý bod
		var _dir = global_position.direction_to(path[1])
		motion += _dir * ACCELERATION
		if global_position == path[0]: #pokud jsme už došli, smazat ten bod z path
			path.remove(0)

func generate_path():
	if player:
		path = navigation.get_simple_path(global_position, player.global_position, false) #start pos, end pos, optimize


func generate_path_for_return():
	path = navigation.get_simple_path(global_position, spawning_position, false)



func choose_dir():
	var choice = Vector2.ZERO
	var rng = RandomNumberGenerator.new()
	
	rng.randomize()
	choice.x = rng.randf_range(-180.0, 180.0)
	rng.randomize()
	choice.y = rng.randf_range(-180.0, 180.0)
	
	return choice


func state_setget(_state):
	var prev_state = state
	if prev_state == CHASE and _state == IDLE: #aby se enemy hned neotočil a šel fuč, když jsem mimo jeho chase range, přp to udělat i s following, nebo tak nějak
		var tim = Timer.new() #vesměs wait(1000), což tu není
		tim.set_wait_time(1)
		tim.set_one_shot(true)
		self.add_child(tim)
		tim.start()
		yield(tim, "timeout")
		tim.queue_free()
		
		state = _state
	else:
		state = _state


func can_chase(): #debilní, ale dejme tomu
	var can_chase = false
	if Globals.player_node:
		var EnemyToPlayer = player.global_position - self.global_position #EP = P-E
		var number_of_path_points = path.size() #1 podlaha = 1 point
		if EnemyToPlayer.length() < 150 and EnemyToPlayer.length() >= 100: #250,180
			if number_of_path_points <= 17:
#				$RayCast_can_see_player.cast_to = EnemyToPlayer
#				if $RayCast_can_see_player.get_collider() == player:
				can_chase = true
				self.state = CHASE
		elif EnemyToPlayer.length() < 100: #180
#			$RayCast_can_see_player.cast_to = EnemyToPlayer
			can_chase = true
			self.state = CHASE
	return can_chase

func should_return():
	var should_return = false
	if state == WANDER:
		var current_position = self.global_position
		var vector_from_curr_to_spawn_pos = spawning_position - current_position
		if vector_from_curr_to_spawn_pos.length() > 200:
			should_return = true
			state = RETURNING
	return should_return


func onGotHitKnockback(knockback_dir) -> void: #Knockback při dostání hitu, přidat ještě knockback force
	if state == CHASE:
		knockback = (position.direction_to(Globals.player_node.global_position)) * (-1) * 140
	else:
		knockback = (position.direction_to(knockback_dir)) * (-1) * 100 #opačný vektor z mé pozice do pozice objektu

func onHitKnockback(area) -> void: #Knockback při hitování hráče
	knockback = ((position.direction_to(area.global_position)) * (-1)) * 140 #random číslo, tak akorát
