extends Area2D

onready  var animationCooldown = $animationCooldown
onready var animPlayer = $AnimationPlayer

var dmg = 10
var knockback_dir

#vybrainit proč 2x Area2D, mby maska? nebo to měl být hitbox?

func _ready() -> void:
	animPlayer.play("peaks")


func _on_Area2D_area_entered(area: Area2D) -> void:
	knockback_dir = (area.global_position - global_position).normalized()
	if not area.is_flying:
		if area.get_parent().name != "Player":
			area.trap_hit()
			area.onHitBySmth(1, knockback_dir) #1 dmg enemákovi stačí, vzhledem k jeho hp
		else:
			area.onHitBySmth(dmg, knockback_dir)

