extends KinematicBody2D


var item_name
var heals = 7
var being_picked_up
var is_player_in_distance = false

func _ready() -> void:
	item_name = "Health_potion"


func _process(delta: float) -> void:
	being_picked_up = $pickup_item_area.being_picked_up
	if Globals.player_node:
		var distance_to_player = global_position.distance_to(Globals.player_node.global_position)
		if distance_to_player <= 50:
			is_player_in_distance = true
		else:
			is_player_in_distance = false
	if is_player_in_distance and !being_picked_up: #ukázaní labelu itemu
		$AnimatedSprite/Label.visible = true
		$AnimatedSprite/Label/AnimationPlayer.play("up_down")
	else:
		$AnimatedSprite/Label.visible = false
		$AnimatedSprite/Label/AnimationPlayer.stop()

func _on_InstantUseArea_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox") and not being_picked_up: #tzn aby mi to nedalo healy, když to beru do invu
		var staty = area.get_parent().stats
		if staty.hasMaxHealth():
			pass
		else:
			$Audio_heal.play()
			number()
			staty._set_health(staty.health + heals)
			queue_free()



func number():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	heals = rng.randi_range(7, 20)
