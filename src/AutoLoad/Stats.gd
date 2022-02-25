extends Node

signal health_updated(health)
signal max_health_updated(max_health)
signal player_health_updated(health)
signal player_max_health_updated(max_health)
signal gold_updated()
signal enemy_died()

export var max_health = 1
onready var health = max_health setget _set_health

var is_killed_by_player: bool = true



func _ready() -> void:
	emit_signal("health_updated", health)
	emit_signal("max_health_updated", max_health)
	Stats.emit_signal("gold_updated")


func _set_health(hp):
	var prev_health = health
	health = clamp (hp, 0, max_health) #hp, minimální hp, max hp
	if health != prev_health:
		if get_parent().name == "Player":
			PlayerStats.emit_signal("player_health_updated", health)
		else:
			emit_signal("health_updated", health)
		if health == 0:
			die()



func hasMaxHealth():
	if max_health == health:
		return true
	else:
		return false


func die():
	if not get_parent().name == "Player":
		if not is_killed_by_player and get_parent().is_in_group("terrorist"): #ať terák, co se odpálí nemá dead animaci, jako když ho zabije hráč.. u ostatních enemy animace je i při zabití trapkou
			pass
		else:
			get_parent().animation_player.play("dead")
			yield(get_parent().animation_player, "animation_finished")
		
		if get_parent().is_in_group("terrorist"): #stopnu mu "pokřik"
			get_parent().audio_bef_expl.stop()
		get_parent().queue_free()
		Stats.emit_signal("enemy_died")
		
		if is_killed_by_player:
			var gold = pick_how_many_golds()
			Globals.golds += gold
			Globals.kills += 1
			Stats.emit_signal("gold_updated")
	else:
		if get_parent().name == "Player":
			Globals.player_node = null
			var curr_scene = get_tree().get_root().get_node("Map") #debilni, ale pokud budu mít perma tohle jako scenu, dá se
			SceneChanger.goto_scene("res://src/Screens/End_screen.tscn", curr_scene)
#			assert(get_tree().change_scene("res://src/Screens/End_screen.tscn") == 0)
		get_parent().queue_free()
	print(str(get_parent().name) + " died")
	
	
	#Pridat animaci, zvuk podle enemy/player


func pick_how_many_golds():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var golds = rng.randi_range(7, 20)
	return golds
