extends Area2D

export var speed = 300
var dmg = 5

func _ready() -> void:
	$AudioStreamPlayer2D.play(0.08)

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	global_position += speed * direction * delta



func destroy():
	queue_free()
	#Pozdeji pridat animaci a zvuk


func _on_VisibilityNotifier2D_screen_exited() -> void:
#	queue_free() 
	pass
	#Mby odstranit, když mapa nebude nekonečná, není nutné i guess


func _on_PlayerGun_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
#		var knockback_dir = (get_parent().global_position - area.global_position).normalized()
		area.onHitBySmth(dmg, global_position) #position kvůli knockbacku
		destroy()


func _on_PlayerGun_body_entered(body: Node) -> void:
	destroy()
	
