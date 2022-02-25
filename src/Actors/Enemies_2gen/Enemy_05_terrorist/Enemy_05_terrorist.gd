extends KinematicBody2D


#onready var navigation: Navigation2D = get_tree().current_scene.get_node("Navigation2D")
onready var navigation: Navigation2D = get_tree().get_root().get_node("Map").get_node("Navigation2D")
onready var stats = $Stats

onready var softColl = $SoftCollision
onready var animation_player = $AnimationPlayer
onready var audio_bef_expl = $Audio_before_explosion

export var ACCELERATION = 300 #Zrychlení
export var FRICTION = 400 #Zpomalení

var knockback = Vector2.ZERO
var motion = Vector2.RIGHT
var can_move = true

var path: PoolVector2Array
var never_played_audio: bool = true

func _physics_process(delta: float) -> void:
	
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	if stats.health == 0: knockback = Vector2.ZERO
	knockback = move_and_slide(knockback)
	
	var direction = Vector2.ZERO
	if Globals.player_node: #když hráč zemře, hodilo by to error cuz == null
		
		if can_move:
			generate_path()
			navigate()
			motion += direction * ACCELERATION

	if softColl.monitorable == true and softColl.monitoring == true:
		if softColl.is_colliding() and $softCollTimer.is_stopped():
			motion = softColl.push_vector() * 50
			$softCollTimer.start()
	
	if stats.health == 0: motion = Vector2.ZERO
	$AnimatedSprite.flip_h = motion.x < 0
	motion = motion.clamped(170)
	motion = move_and_slide(motion)

func navigate():
	if path.size() > 0: #pokud je cesta, tak pohyb na druhý bod
		var _dir = global_position.direction_to(path[1])
		motion += _dir * ACCELERATION
		if global_position == path[0]: #pokud jsme už došli, smazat ten bod z path
			path.remove(0)

func generate_path():
	path = navigation.get_simple_path(global_position, Globals.player_node.global_position, true) #start pos, end pos, optimize



func onGotHitKnockback(knockback_dir) -> void: #Knockback při dostání hitu
	knockback = (position.direction_to(knockback_dir)) * (-1) * 100 #opačný vektor z mé pozice do pozice objektu


func _on_Area2D2_area_entered(area: Area2D) -> void:#Hitbox_wannabe, hituje hráče
	#detekce hráče a bum
	
	if area.is_in_group("player_hurtbox"):
		$Sprite2.visible = true #sprite2 = exploze, mby debilně udělané, whatever
		$Light2D.visible = true
		$AnimationPlayer.play("explosion")
		can_move = false
		motion = Vector2.ZERO
		var dmg = 50
		var knockback_dir = (area.global_position - get_parent().global_position).normalized()
		area.onHitBySmth(dmg, knockback_dir)
		$AnimatedSprite.visible = false
		$Hurtbox.remove_from_group("enemy_hurtbox")#vymažu hurtbox z groupky = nebude to detekovat meč/zbraň = nemůžu ho "zabít" až vybouchne, tzn exploze zůstane, debilně udělané, ale co
		#mby exploze scene sama o sobě, pak se jen spawne = enemy se může smazat hned, jen exploze zůstane
		
		yield($AnimationPlayer, "animation_finished")
		stats.is_killed_by_player = false
		stats._set_health(0) #hp na 0, aby se enemy smazal/zabil


func _on_Area2D_area_entered(area: Area2D) -> void: 
	if never_played_audio:
		$Audio_before_explosion.play()
		never_played_audio = false
#		yield($Audio_before_explosion, "finished")
#		$Audio_before_explosion.stop()


