extends Area2D

export var speed = 200

var direction
#Layer 13 je kvuli meči

func _physics_process(delta: float) -> void:
	direction = Vector2.RIGHT.rotated(rotation)
	global_position += speed * direction * delta

func destroy():
	queue_free()
	#Pozdeji pridat animaci a zvuk


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()


func _on_EnemyGun_body_entered(body: Node) -> void:
	if body.is_in_group("enemy_shooter"):
		pass
	else:
		queue_free() #trigruje to svět
		
#udělat ať to hituje enemy, minimálně ať se zničí při kontaktu -> ale aby se neničilo při kontaktu s parentem

func _on_Hitbox_area_entered(area: Area2D) -> void:
#	if area.is_in_group("player_hurtbox"):
	destroy()


func _on_EnemyGun_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_sword"):
		var idk = (position.direction_to(area.global_position) * (-1)).angle() #knockback střely někam
		rotation = idk
#		destroy()


