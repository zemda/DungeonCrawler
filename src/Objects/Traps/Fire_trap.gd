extends Area2D


#Pokus, někdy dodělat pokud se mi bude chtít
#Přidat alespoň 1 mezi frame a udělat to delší mby = +3 mezi frames minimálně
#If hit player: boom animace třeba a visibility false/end, to samé pak s jinými traps


func _ready() -> void:
	$Sprite.visible = false


func _on_Fire_trap_area_entered(area: Area2D) -> void:
	$Sprite.visible = true
	$Sprite.playing = true


func _on_Fire_trap_area_exited(area: Area2D) -> void:
	$Sprite.visible = false
	$Sprite.playing = false
