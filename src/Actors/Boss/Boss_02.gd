extends KinematicBody2D


onready var stats = $Stats
onready var player: KinematicBody2D = get_tree().get_root().get_node("Map").get_node("Player")
onready var attackCooldown = $Attack_cooldown
onready var animation_player = $AnimationPlayer


export var ACCELERATION = 300 #Zrychlení
export var FRICTION = 150 #Zpomalení

var max_speed = 110
var knockback = Vector2.ZERO
var motion = Vector2.ZERO


func _ready() -> void:
	$AnimatedSprite.play("run")

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	if stats.health == 0: knockback = Vector2.ZERO
	knockback = move_and_slide(knockback)
	
	if Globals.player_node: #když hráč zemře, hodilo by to error cuz == null
		direction = position.direction_to(Globals.player_node.global_position)
		motion += direction * ACCELERATION
	
	
	if motion.x < 0:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false
	
	if randi() % 2500 == 10:
		max_speed = 300
		motion = motion * 8
		modulate.a = 0.5
		var tim = Timer.new()
		add_child(tim)
		tim.start(0.4)
		yield(tim, "timeout")
		max_speed = 110
		modulate.a = 1
	
	
	motion = motion.clamped(max_speed)
	if stats.health == 0: motion = Vector2.ZERO
	motion = move_and_slide(motion)


func onGotHitKnockback(knockback_dir) -> void: #Knockback při dostání hitu, přidat ještě knockback force
	knockback = (position.direction_to(Globals.player_node.global_position)) * (-1) * 100


func onHitKnockback(area) -> void: #Knockback při hitování hráče
	knockback = ((position.direction_to(area.global_position)) * (-1)) * 140 #random číslo, tak akorát
