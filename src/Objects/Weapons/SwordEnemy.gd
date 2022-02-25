extends KinematicBody2D


var rot = 0;
const START_ANGLE = -45
const END_ANGLE = 45


func _ready():
	$AnimationPlayer.play("attackAnim", -1, 5.0)
	if rot > 0:
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 0, START_ANGLE + rot)
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 1, END_ANGLE + rot)
	else:
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 1, START_ANGLE + rot)
		$AnimationPlayer.get_animation("attackAnim").track_set_key_value(0, 0, END_ANGLE + rot)


func _on_AnimationPlayer_animation_finished(anim_name) -> void:
	queue_free()

