extends Control

onready var health_over = $HealthOver #nefunguje idk


func _on_Stats_health_updated(health) -> void: #Enemy
	$HealthOver.set_value(health)# = health
#	print(str(get_parent().name) + " hp updated: "+ str(health))

func _on_Stats_max_health_updated(max_health) -> void: #Enemy
	$HealthOver.max_value = max_health
#	print(str(get_parent().name) + " max hp updated: "+ str(max_health))
