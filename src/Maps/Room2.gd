extends TileMap

const BOSS = {
	0: preload("res://src/Actors/Enemies_2gen/Enemy_07_sword/Enemy_07_sword.tscn")
}

onready var main = get_tree().get_root().get_node("Map")
onready var main_nav: Navigation2D = get_tree().get_root().get_node("Map").get_node("Navigation2D")

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

		var tim = Timer.new() #bcs nemuzu při area_entered hned spawnovat něco jiného bez call_defered, kterej pak ale dává error u střílejících enemy
		add_child(tim)
		tim.start(0.3)
		yield(tim, "timeout")
		tim.queue_free()
		
		var boss_ = BOSS[0].instance()
		
		var pos
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
		


func on_room_area_entered(area) -> void:
	$Detect_close_doors.queue_free()
	
	$Doors/Doors_front.close_doors()
	$Doors/Doors_front2.close_doors()
	


func on_enemy_died() -> void:
	enemies_alive -= 1
	enemies_alive = clamp(enemies_alive, 0, 1000)
	if enemies_alive == 0:
		var tim = Timer.new()
		add_child(tim)
		tim.start(2)
		#label win
		yield(tim, "timeout")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		SceneChanger.goto_scene("res://src/Screens/End_screen_win.tscn", main)
		var xd = get_tree().get_root().get_node("Map").get_node("Audio_background")
		xd.stop()
