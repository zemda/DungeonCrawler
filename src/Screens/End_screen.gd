extends "res://src/Screens/Start_screen.gd"


func _ready() -> void:
	$Label_kills.text = "Kills: %s" % Globals.kills #stačí ready, cuz se spustí až po smrti hráče

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		match selected:
			OPTION_START:
				Globals.emit_signal("retry")
				#Jelikož základní ovládání je stejné jak ve start screenu, tak jej jen extenduju a nic není navíc = tady alespoň při retry musím vymazat inv atp
				#nahouby, ale funguje a lepší jak mít stejný kód 2x
				#bylo by lepší udělat zvlášť script pro labely = reusable


func _on_Label_start_gui_input(event: InputEvent) -> void: #retry, LABELY NA KLIK MYŠÍ, ZBYTEK JE V START SCREEN
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		selected = OPTION_START
		$Label_switch.play()
		changed = true
#		assert(get_tree().change_scene(next_scene_path) == 0)
		Globals.emit_signal("retry")
		SceneChanger.goto_scene(next_scene_path, self)

func _on_Label_settings_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		selected = OPTION_SETTINGS
		$Label_switch.play()
		changed = true
		self.toggleSettings = !toggleSettings

func _on_Label_quit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		selected = OPTION_QUIT
		$Label_switch.play()
		changed = true
		get_tree().quit()


func toggleSettings_(value):
	toggleSettings = value
	$Label_you_died.visible = !value
	$Settings.visible = value
	$CenterContainer.visible = !value
	$Right.visible = !value



func _on_Settings_settings_label_back() -> void:
	self.toggleSettings = !toggleSettings
