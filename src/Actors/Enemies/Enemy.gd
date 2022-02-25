extends KinematicBody2D


enum {
	IDLE,		#0
	WANDER,		#1
	CHASE,		#2
	FOLLOWING	#3
}

onready var stats = $Stats

onready var AttackCooldownTim = $AttackCooldown
onready var AttackCooldownTim2 = $AttackCooldown2
onready var softColl = $SoftCollision
onready var state = WANDER setget state_setget
onready var animation_player = $AnimationPlayer

export var ACCELERATION = 300 #Zrychlení
export var FRICTION = 150 #Zpomalení


var knockback = Vector2.ZERO
var motion = Vector2.ZERO
var speed = 70

var dir = Vector2.ZERO

var _last_dir: = Vector2(1.0, 0.0)
var _attack_dir: = Vector2(1.0, 0.0)

var attack_angle
var last_dir_angle 

func _ready() -> void:
	AttackCooldownTim.start()
	AttackCooldownTim2.start()

#The _physics_process() runs at a fixed rate that doesn't change, I believe by default it runs at 60 times a second.
#The _process() would run every single frame, so the amount of times it's called can change every second.
func _physics_process(delta: float) -> void:
	
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	if stats.health == 0: knockback = Vector2.ZERO
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			$AnimatedSprite.play("idle")
			motion = motion.move_toward(Vector2.ZERO, FRICTION * delta)
			can_follow_or_chase_player()
			
			if !can_follow_or_chase_player():
				self.state = WANDER

		WANDER: #edit, wandering pouze v nějakém imaginárním boxu, nebo jít doprava, vrátit se na default spot nějak, jít jinam, a dokola 
			if $moveTimer.is_stopped():
				$moveTimer.start()
				dir = choose_dir()
				motion = motion.move_toward(dir * 20, ACCELERATION * delta)
			motion = motion.move_toward(dir * speed, ACCELERATION * delta)
			
			var idk = _last_dir.normalized()
			$RandomMove.cast_to = idk * 7
			if $RandomMove.is_colliding():
				dir = choose_dir()
				motion = motion.move_toward(dir * 20, ACCELERATION * delta)
			
			can_follow_or_chase_player()
		
		CHASE:
			var direction = Vector2.ZERO
			if Globals.player_node: #když hráč zemře, hodilo by to error cuz == null
				direction = position.direction_to(Globals.player_node.global_position)
			
			if self.has_method("move_away_from_player"): #Dát jinej if, pokud nepřidám něco do té funkce
				motion = motion.move_toward(-direction * speed, ACCELERATION * delta)
			else:
				motion = motion.move_toward(direction * speed, ACCELERATION * delta)
			$AnimatedSprite.flip_h = motion.x < 0
			
			if !can_follow_or_chase_player():
				self.state = IDLE
	
		FOLLOWING:
			var direction = Vector2.ZERO
			if Globals.player_node: 
				direction = position.direction_to(Globals.player_node.global_position)
			motion = motion.move_toward(direction * (speed/2), ACCELERATION * delta)
			
			if !can_follow_or_chase_player():
				self.state = IDLE
	
	if state != IDLE:
		$AnimatedSprite.play("run")
	
	if softColl.monitorable == true and softColl.monitoring == true:
		if softColl.is_colliding() and $softCollTimer.is_stopped():
			motion = softColl.push_vector() * 50
			$softCollTimer.start()
	
	if stats.health == 0: motion = Vector2.ZERO
	motion = motion.clamped(80)
	motion = move_and_slide(motion)
	_get_direction(motion)

func _process(delta: float) -> void:
	last_dir_angle = rad2deg(_last_dir.angle())
	attack_angle = rad2deg(_attack_dir.angle())


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


func choose_dir():
	var choice = Vector2.ZERO
	
	var rng = RandomNumberGenerator.new()
	
	rng.randomize()
	choice.x = rng.randf_range(-180.0, 180.0)
	rng.randomize()
	choice.y = rng.randf_range(-180.0, 180.0)
	
	return choice


func can_follow_or_chase_player():
	var can_follow = false
	var player = Globals.player_node
	if player:
		var EnemyToPlayer = player.global_position - self.global_position
		if EnemyToPlayer.length() < 180 and EnemyToPlayer.length() > 120: #Delší cast, slowly following //180
			if is_facing_cast():
				can_follow = true
				self.state = FOLLOWING
		
		elif EnemyToPlayer.length() <= 120 and EnemyToPlayer.length() > 90: #Kratší cast, chase if facing //120
			if is_facing_cast():
				can_follow = true
				self.state = CHASE
		
		elif EnemyToPlayer.length() <= 90: #Nejbližší cast, chase i bez facingu
			$MoveTowardPlayer.cast_to = $MoveTowardPlayer.to_local(player.global_position) #k nicemu, ale vypadá to líp, než kdyby tam byl v random směru
			can_follow = true
			self.state = CHASE
	
	return can_follow

func is_facing_cast(): #abych nemusel mít facing a ty 2 ify 2x napsané, funkce
	var cast = false
	var EnemyToPlayer = Globals.player_node.global_position - self.global_position
	var facing = Vector2.RIGHT.rotated(_last_dir.angle())
	if EnemyToPlayer.normalized().dot(facing) > 0: #Viz facing/dot product v docs, fov je ale 180
		$MoveTowardPlayer.cast_to = $MoveTowardPlayer.to_local(Globals.player_node.global_position)
		$MoveTowardPlayer.cast_to += $MoveTowardPlayer.cast_to.normalized()
		if $MoveTowardPlayer.get_collider() == Globals.player_node:
			cast = true
	return cast

func _get_direction(motionn) -> void:
	var new_dir = Vector2(motionn)
	if new_dir != Vector2.ZERO: #Pokud se pohneme, tak se aktualizuji promenne
		_attack_dir = new_dir
		_last_dir = new_dir


func onGotHitKnockback(knockback_dir) -> void: #Knockback při dostání hitu
	if state == CHASE:
		if Globals.player_node:
			knockback = (position.direction_to(Globals.player_node.global_position)) * (-1) * 140
	else: #nahore playerDetection.player.global_position
		knockback = (position.direction_to(knockback_dir)) * (-1) * 100 #opačný vektor z mé pozice do pozice objektu


func onHitKnockback(area) -> void: #Knockback při hitování hráče
	knockback = ((position.direction_to(area.global_position)) * (-1)) * 140 #random číslo, tak akorát

#func hpGenerator():
#	var rng = RandomNumberGenerator.new()
#	rng.randomize()
#	var hp = rng.randi_range(12, 25)
#	return hp
#Někdy dodělat, aby se začínalo s random hp
