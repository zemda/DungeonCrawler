extends TileMap

const BOSS = {
	0: preload("res://src/Actors/Boss/Boss_02.tscn")
}

onready var skeleton = preload("res://src/Actors/Boss/Enemy_skel.tscn")
onready var sword = preload("res://src/Actors/Enemies_2gen/Enemy_07_sword/Enemy_07_sword.tscn")

onready var main = get_tree().get_root().get_node("Map")
onready var main_nav: Navigation2D = get_tree().get_root().get_node("Map").get_node("Navigation2D")
onready var enemy_pos = $Enemy_pos
onready var enemy_pos2 = $Enemy_pos2

var has_entered: bool = false
var enemies_alive


func _ready() -> void:
	assert(Stats.connect("enemy_died", self, "on_enemy_died") == 0)
	assert($Player_detector.connect("area_entered", self, "on_open_doors_area_entered") == 0)
	assert($Detect_close_doors.connect("area_entered", self, "on_room_area_entered") == 0)
	enemies_alive = get_tree().get_nodes_in_group("enemy").size()

func on_open_doors_area_entered(area) -> void:
	$Player_detector.queue_free()
	
	if not has_entered:
		has_entered = true
		$Doors/Doors_front.open_doors()
		$Doors/Doors_front2.open_doors()



func on_room_area_entered(area) -> void:
	$Detect_close_doors.queue_free()
	
	$Doors/Doors_front.close_doors()
	$Doors/Doors_front2.close_doors()
	
	spawn_enemies()

func spawn_enemies():
	var tim = Timer.new() #bcs nemuzu při area_entered hned spawnovat něco jiného
	add_child(tim)
	tim.start(0.3)
	yield(tim, "timeout")
	tim.queue_free()
	
	var boss_ = BOSS[0].instance()
	var skel_ = skeleton.instance()
	
	var rand = randi() % 3
	if rand == 0 :
		boss_.position = $Positions/Spawn0.global_position
	elif rand == 1 :
		boss_.position = $Positions/Spawn1.global_position
	elif rand == 2 :
		boss_.position = $Positions/Spawn2.global_position
	elif rand == 3 :
		boss_.position = $Positions/Spawn3.global_position
		
	main.add_child(boss_)
#	main.call_deferred("add_child", boss_)
	boss_.set_owner(main)

	
	for e_pos in enemy_pos.get_children():
		var _skel = skeleton.instance()
		_skel.position = e_pos.position
		main.add_child(_skel)
#		main.call_deferred("add_child", _skel) -> pak ale nejde owner, cuz není ještě přidanej
		_skel.set_owner(main)
	
	for e_pos2 in enemy_pos2.get_children():
		var _sword = sword.instance()
		_sword.position = e_pos2.position
		main.add_child(_sword)
		_sword.set_owner(main)
	
	enemies_alive = get_tree().get_nodes_in_group("enemy").size()



func on_enemy_died() -> void:
	enemies_alive -= 1
	enemies_alive = clamp(enemies_alive, 0, 1000)
	if enemies_alive == 0:
		var label = preload("res://src/UI/Label.tscn")
		var lab = label.instance()
		lab.text = "You have won!"
		lab.set_align(Label.ALIGN_CENTER)
		lab.set_margin(MARGIN_TOP, 150)
		main.get_node("UI").get_node("Player_UI").add_child(lab)

		var tim = Timer.new()
		add_child(tim)
		tim.start(2)
		yield(tim, "timeout")
		lab.queue_free()
		tim.queue_free()
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var xd = get_tree().get_root().get_node("Map").get_node("Audio_background")
		xd.stop()
		SceneChanger.goto_scene("res://src/Screens/End_screen_win.tscn", main)
		
