extends KinematicBody2D


var rot = 0;
const START_ANGLE = -45
const END_ANGLE = 45
var dmg = 10


func _ready():
	$AnimationPlayer.play("attackAnim", -1, 5.0)
	$AudioStreamPlayer2D.play()
	if rot > 0:
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 0, START_ANGLE + rot)
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 1, END_ANGLE + rot)
	else:
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 1, START_ANGLE + rot)
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 0, END_ANGLE + rot)


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()


func _on_Area2D_area_entered(area: Area2D) -> void:
	var knockback_dir = (area.global_position - get_parent().global_position).normalized()
	if area.is_in_group("enemy_hurtbox"):
		area.onHitBySmth(dmg, knockback_dir)
		

