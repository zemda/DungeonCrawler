extends StaticBody2D

func _ready():
	$AnimationPlayer.play("RESET")

func open_doors() -> void:
	$AnimationPlayer.play("doors_open")

func close_doors() -> void:
	$AnimationPlayer.play("doors_close")
