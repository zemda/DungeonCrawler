extends Node2D

const ENEMY_SCENES: Dictionary = {
	0:preload("res://src/Actors/Enemies/Enemy_01_normal/Enemy_01_normal.tscn"),
	1:preload("res://src/Actors/Enemies/Enemy_02_sword/Enemy_02_sword.tscn"),
	2:preload("res://src/Actors/Enemies/Enemy_03_gun/Enemy_03_gun.tscn"),
	3:preload("res://src/Actors/Enemies/Enemy_04_bat/Enemy_04_bat.tscn"),
	"Terrorist":preload("res://src/Actors/Enemies_2gen/Enemy_05_terrorist/Enemy_05_terrorist.tscn"),
	4:preload("res://src/Actors/Enemies_2gen/Enemy_06_skeleton/Enemy_06_skeleton.tscn"),
	5:preload("res://src/Actors/Enemies_2gen/Enemy_07_sword/Enemy_07_sword.tscn"),
}

const NON_PICKABLE_ITEMS: Dictionary = {
	0:preload("res://src/Objects/Potions/HealPotion.tscn"),
	1:preload("res://src/Objects/Potions/RandomEffectPotion.tscn"),
}

const SCENE_TRAPS: Dictionary = {
	0:preload("res://src/Objects/Peaks.tscn")
}

const PICKABLE_HEAL = preload("res://src/Objects/Pickable_items/Item_HealthPotion.tscn")

const ROOMS: Dictionary = {
	0: preload("res://src/Maps/Room1.tscn"),
	1: preload("res://src/Maps/Room2.tscn"),
}


var enemies_alive
var has_entered = false
var has_spawned = false

#Script k Map/map01
func _ready() -> void: #TOHLE NĚJAK ASI UPRAVIT, ABY TO BYLO LEPŠÍ, není to jistota
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	$Player/player_hurtbox/CollisionShape2D.disabled = true
	
	set_players_pos()
	spawn_enemies(0)
	spawn_items_and_objects()
	
#	$Before_start_emit_timer.start()
#	yield($Before_start_emit_timer, "timeout")
	Globals.emit_signal("start_game") #spustí se funkce v PlayerStats, bcs to mám debilně udělá, ale whatever

	$Player/player_hurtbox/CollisionShape2D.disabled = false
	enemies_alive = get_tree().get_nodes_in_group("enemy").size()
	assert(Stats.connect("enemy_died", self, "on_enemy_died") == 0)
	
	if enemies_alive <= 0:
		on_enemy_died()
	
	$Audio_background.play()



func set_players_pos():
	var random_cell = pick_random_floor()
	$Player.position = random_cell * 16



func spawn_enemies(num) -> void:
	for i in range(num):#spawn enemáků
		var monster: KinematicBody2D
		
		if randi() % 100 == 1: #malá šance na spawn speciálního nepřítele
			monster = ENEMY_SCENES.Terrorist.instance()
		else:
			var random_choose = randi() % 6 #random 0-5, 6 enemy
			monster = ENEMY_SCENES[random_choose].instance()
		
		var random_cell = pick_random_floor()
		monster.position = random_cell * 16
		
#		call_deferred("add_child", monster)
		add_child(monster)
		monster.set_owner(self)


func spawn_items_and_objects() -> void:
	for z in range(5): #traps
		var trap
		trap = SCENE_TRAPS[0].instance()

		var random_cell = pick_random_floor()
		var spawning_pos = random_cell * 16

		trap.position = spawning_pos
		add_child(trap)

	for i in range(2): #itemy
		var item
		var random_choose = randi() % 2 #random 0-1, 2 itemy zatím
		item = NON_PICKABLE_ITEMS[random_choose].instance()
		var random_cell = pick_random_floor()
		var spawning_pos = random_cell * 16

		item.position = spawning_pos
		add_child(item)

	for r in range(3): #pickable heal
		var item
		item = PICKABLE_HEAL.instance()
		var random_cell = pick_random_floor()
		var spawning_pos = random_cell * 16

		item.position = spawning_pos
		add_child(item)


func pick_random_floor(): #z celého mapy
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var floors: Array = $Navigation2D/TileMap.get_used_cells_by_id(8) #8 je id podlahy
	
	return floors[rng.randi_range(0, floors.size()-1)]


func on_enemy_died() -> void:
	print(enemies_alive)
	enemies_alive -= 1
	enemies_alive = clamp(enemies_alive, 0, 1000)
	if enemies_alive == 0:
		$Doors_side_left.open_doors()
		var room = ROOMS[0].instance()
		$Navigation2D.add_child(room)
		Stats.disconnect("enemy_died", self, "on_enemy_died")
		
