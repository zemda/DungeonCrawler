extends Node

signal retry

signal start_game #kvůli hotbaru v PlayerStats, ať to načtu jakmile startnu hru ze start screenu

var player_node: KinematicBody2D

var can_jump = false #aby hráč mohl při boss fightu "skákat"
var is_in_opened = false

var kills = 0
var golds = 0

func _ready() -> void:
	assert(connect("retry", self, "reset_all_cuz_retry") == 0)
	
#	var mouse_arrow = preload("res://assets/cursor/normal.png")
	var mouse_arrow2 = preload("res://assets/cursor/normal_alternate.png")
	Input.set_custom_mouse_cursor(mouse_arrow2, Input.CURSOR_ARROW)
	
	var mouse_hand = preload("res://assets/cursor/link select.png")
	Input.set_custom_mouse_cursor(mouse_hand,  Input.CURSOR_POINTING_HAND)
	


func reset_all_cuz_retry():
	kills = 0
	golds = 0
	PlayerStats.retry_game()
