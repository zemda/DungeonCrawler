extends KinematicBody2D


var rot = 0;
const START_ANGLE = 0
const MIDD_ANGLE = -5
const END_ANGLE = -10
var dmg = 14


func _ready():
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("attackAnim", -1, 2.3)
	$AudioStreamPlayer2D.play()

	
	#why key-sekunda nefunguje jak má??
	#track_set_key_value(track_idx: int, key: int, value: Variant) -> key: int?
	if rot == 90:#doprava
		#id tracku - první je rotace, key - sekunda, value - musím přidat stupně podle toho, kam hráč útočí
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 0, 0 + rot)
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 0.5, -5 + rot)
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 1, -10 + rot)
		
		#id tracku - první je pozice, key - sekunda, value - x/y se musí změnit obv
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(1, 0, Vector2(0,0))
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(1, 0.5, Vector2(13,0))
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(1, 1, Vector2(0,0))
	elif rot == -90: #vlevo
		#id tracku - první je rotace, key - sekunda, value - musím přidat stupně podle toho, kam hráč útočí
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 0, 0 + rot)
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 0.5, 5 + rot)
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 1, 10 + rot)
		
		#id tracku - první je pozice, key - sekunda, value - x/y se musí změnit obv
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(1, 0, Vector2(0, 0))
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(1, 0.5, Vector2(-13, 0))
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(1, 1, Vector2(0, 0))
	elif rot == 180: #dolu
		#id tracku - první je rotace, key - sekunda, value - musím přidat stupně podle toho, kam hráč útočí
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 0, 0 + rot)
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 0.5, 5 + rot)
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 1, 10 + rot)
		
				#id tracku - první je pozice, key - sekunda, value - x/y se musí změnit obv
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(1, 0, Vector2(0, 0))
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(1, 0.5, Vector2(0, 13))
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(1, 1, Vector2(0, 0))
	elif rot == 0: #nahoru
		#id tracku - první je rotace, key - sekunda, value - musím přidat stupně podle toho, kam hráč útočí
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 0, 0 + rot)
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 0.5, 5 + rot)
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 1, 10 + rot)
		
		#id tracku - první je pozice, key - sekunda, value - x/y se musí změnit obv
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(1, 0, Vector2(0,0))
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(1, 0.5, Vector2(0, -13))
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(1, 1, Vector2(0,0))
	else:
		print("nemelo by se stat")
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 1, -5 + rot)
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 0, 0 + rot)


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()


func _on_Area2D_area_entered(area: Area2D) -> void:
	var knockback_dir = (area.global_position - get_parent().global_position).normalized()
	if area.is_in_group("enemy_hurtbox"):
		area.onHitBySmth(dmg, knockback_dir)
		

