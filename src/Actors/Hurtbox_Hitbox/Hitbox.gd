extends Area2D

#uděluje dmg hráči

export var damage = 1 #-> v každé scéně u enemáka/zbraně se nastaví 

func _on_Hitbox_area_entered(area: Area2D) -> void:
	var knockback_dir = (area.global_position - get_parent().global_position).normalized()
	area.onHitBySmth(damage, knockback_dir)
	if get_parent().has_method("onHitKnockback"):
		get_parent().onHitKnockback(area) #Knockback při hitování hráče

func _on_Hitbox_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
