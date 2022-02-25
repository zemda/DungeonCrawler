extends Node2D
signal settings_label_back()

onready var master_vol = $CenterContainer/GridContainer2/GridContainer/HSlider_master
onready var music_vol = $CenterContainer/GridContainer2/GridContainer/HSlider2_Music
onready var sfx_vol = $CenterContainer/GridContainer2/GridContainer/HSlider3_sfx

const OPTION_MASTER = 0
const OPTION_MUSIC = 1
const OPTION_SFX = 2
const OPTION_BACK = 3

var selected = 0
var changed = false

func _ready() -> void: #aby se vizuálně načetly na ty hodnoty i v jiné scéně
	$CenterContainer/GridContainer2/GridContainer/HSlider_master.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	
	$CenterContainer/GridContainer2/GridContainer/HSlider2_Music.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	
	$CenterContainer/GridContainer2/GridContainer/HSlider3_sfx.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sfx"))

func _input(event: InputEvent) -> void:
	if visible == true:
		if event.is_action_pressed("ui_cancel"):#tohle trigruje ale i unhandled input, takže to dá paused false
			get_tree().set_input_as_handled()
			emit_signal("settings_label_back")
			selected = OPTION_MASTER
			changed = true
		
		if event.is_action_pressed("ui_down"):
			if selected == OPTION_MASTER:
				selected = OPTION_MUSIC
				$Label_switch.play()
				changed = true
			elif selected == OPTION_MUSIC:
				selected = OPTION_SFX
				$Label_switch.play()
				changed = true
			elif selected == OPTION_SFX:
				selected = OPTION_BACK
				$Label_switch.play()
				changed = true
	
		elif event.is_action_pressed("ui_up"):
			if selected == OPTION_BACK:
				selected = OPTION_SFX
				$Label_switch.play()
				changed = true
			elif selected == OPTION_SFX:
				selected = OPTION_MUSIC
				$Label_switch.play()
				changed = true
			elif selected == OPTION_MUSIC:
				selected = OPTION_MASTER
				$Label_switch.play()
				changed = true
		
	#reset animace = if changed:
		if selected == OPTION_MASTER:
			if changed:
				$AnimationPlayer.play("RESET")
				changed = false
				yield($AnimationPlayer, "animation_finished")
			$AnimationPlayer.play("selected_master")
		elif selected == OPTION_MUSIC:
			if changed:
				$AnimationPlayer.play("RESET")
				changed = false
				yield($AnimationPlayer, "animation_finished")
			$AnimationPlayer.play("selected_music")
		elif selected == OPTION_SFX:
			if changed:
				$AnimationPlayer.play("RESET")
				changed = false
				yield($AnimationPlayer, "animation_finished")
			$AnimationPlayer.play("selected_sfx")
		elif selected == OPTION_BACK:
			if changed:
				$AnimationPlayer.play("RESET")
				changed = false
				yield($AnimationPlayer, "animation_finished")
			$AnimationPlayer.play("selected_back")
	
		match selected:
			OPTION_MASTER:
				if event.is_action("ui_left"):
					master_vol.set_value(master_vol.value - 1)
				elif event.is_action("ui_right"):
					master_vol.set_value(master_vol.value + 1)
			OPTION_MUSIC:
				if event.is_action("ui_left"):
					music_vol.set_value(music_vol.value - 1)
				elif event.is_action("ui_right"):
					music_vol.set_value(music_vol.value + 1)
			OPTION_SFX:
				if event.is_action("ui_left"):
					sfx_vol.set_value(sfx_vol.value - 1)
				elif event.is_action("ui_right"):
					sfx_vol.set_value(sfx_vol.value + 1)
			OPTION_BACK:
				if event.is_action_pressed("ui_accept"):
					get_tree().set_input_as_handled()
					emit_signal("settings_label_back")
					selected = OPTION_MASTER
					changed = true
					$Label_switch.play()



func _on_HSlider_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), $CenterContainer/GridContainer2/GridContainer/HSlider_master.value)


func _on_HSlider2_Music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), $CenterContainer/GridContainer2/GridContainer/HSlider2_Music.value)


func _on_HSlider3_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sfx"), $CenterContainer/GridContainer2/GridContainer/HSlider3_sfx.value)



func _on_Label_back_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("settings_label_back")
		$Label_switch.play()
		selected = OPTION_MASTER
		changed = true



func _on_HSlider_master_mouse_entered() -> void:
	if selected != OPTION_MASTER:
		changed = true
	$AnimationPlayer.play("RESET")
	selected = OPTION_MASTER


func _on_HSlider2_Music_mouse_entered() -> void:
	if selected != OPTION_MUSIC:
		changed = true
	$AnimationPlayer.play("RESET")
	selected = OPTION_MUSIC


func _on_HSlider3_sfx_mouse_entered() -> void:
	if selected != OPTION_SFX:
		changed = true
	$AnimationPlayer.play("RESET")
	selected = OPTION_SFX
	
