extends Control

const OPTION_START = 0
const OPTION_SETTINGS = 1
const OPTION_QUIT = 2
export(String, FILE) var next_scene_path: = ""

var toggleSettings: bool = false setget toggleSettings_

var selected = 0
var changed = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$AnimationPlayer.play("selected_start")

func _input(event: InputEvent) -> void:
	if event.is_action_released("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	if event.is_action_pressed("ui_down"):
		if selected == OPTION_START:
			selected = OPTION_SETTINGS
			$Label_switch.play()
			changed = true
		elif selected == OPTION_SETTINGS:
			selected = OPTION_QUIT
			$Label_switch.play()
			changed = true
	
	elif event.is_action_pressed("ui_up"):
			if selected == OPTION_QUIT:
				selected = OPTION_SETTINGS
				$Label_switch.play()
				changed = true
			elif selected == OPTION_SETTINGS:
				selected = OPTION_START
				$Label_switch.play()
				changed = true
		
	#reset animace = if changed:, nejde ve funkci, idk why
	if selected == OPTION_START:
		if changed:
			$AnimationPlayer.play("RESET")
			changed = false
			yield($AnimationPlayer, "animation_finished")
		$AnimationPlayer.play("selected_start")
	elif selected == OPTION_SETTINGS:
		if changed:
			$AnimationPlayer.play("RESET")
			changed = false
			yield($AnimationPlayer, "animation_finished")
		$AnimationPlayer.play("selected_settings")
	elif selected == OPTION_QUIT:
		if changed:
			$AnimationPlayer.play("RESET")
			changed = false
			yield($AnimationPlayer, "animation_finished")
		$AnimationPlayer.play("selected_quit")
		
	if event.is_action_pressed("ui_accept"):
		match selected: #až něco přidám, přidat to i dole do mouse clicked labels
			OPTION_START:
#				yield(get_tree(), "idle_frame")
#				assert(get_tree().change_scene(next_scene_path) == 0)
				SceneChanger.goto_scene(next_scene_path, self)
				
#				Globals.emit_signal("start_game") #emitnout až je načtené, bcs jak se načte, tak hned se spouští 
				#HBslots = hotbarSlots.get_children(), jinak error obv, cuz null instance
			OPTION_SETTINGS:
				self.toggleSettings = !toggleSettings
			OPTION_QUIT:
				get_tree().quit()
	
	
	#Setings
#	if toggleSettings:
#		if event.is_action_pressed("ui_cancel"):
#			self.toggleSettings = false


func _get_configuration_warning() -> String:
	return "next_scene_path must be set" if next_scene_path == "" else ""


func _on_Label_start_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		selected = OPTION_START
		$Label_switch.play()
		changed = true
#		assert(get_tree().change_scene(next_scene_path) == 0)
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
	$Label_name.visible = !value
	$Settings.visible = value
	$CenterContainer.visible = !value
	$Right.visible = !value
	


func _on_Settings_settings_label_back() -> void:
	self.toggleSettings = !toggleSettings
