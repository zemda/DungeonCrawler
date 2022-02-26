extends Control

signal inv_was_opened
signal inv_was_closed

onready var scene_tree = get_tree()
onready var pause_overlay = $PauseOverlay
onready var player_health = $Player_health
onready var inventory = $Inventory

#Mby přidat option reset/reload, get_tree().reload_current_scene()
#------- PAUSE OVERLAY -------#
const OPTION_CONTINUE = 0
const OPTION_SETTINGS = 1
const OPTION_QUIT = 2

var selected = 0
var changed = false
#------- PAUSE OVERLAY -------#


var holding_item = null #UI je parent invu i hotbaru, chceme to spolu sharovat (item co pretahujeme, ne co je aktivní v hotbaru)

var paused := false setget set_paused
var toggleInvent: bool = false setget toggleInventory
var toggleShop: bool = false setget toggleShop_
var toggleSettings: bool = false setget toggleSettings_

func _ready() -> void:
	assert(Stats.connect("gold_updated", self, "gold_updated") == 0)
	assert(PlayerStats.connect("player_health_updated", self, "_on_PlayerStats_player_health_updated") == 0)
	assert(PlayerStats.connect("player_max_health_updated", self, "_on_PlayerStats_player_max_health_updated") == 0)


func _input(event) -> void:
	if not paused:
		if event.is_action_pressed("inventory"):
			if toggleShop != true:
				self.toggleInvent = !toggleInvent
		elif event.is_action_pressed("shop"):
			self.toggleShop = !toggleShop
		
		if event.is_action_pressed("prev_hotbar_slot"):
			PlayerStats.active_prev_item()
		elif event.is_action_pressed("next_hotbar_slot"):
			PlayerStats.active_next_item()
		elif event.is_action_pressed("slot1"):
			PlayerStats.active_first_item()
		elif event.is_action_pressed("slot2"):
			PlayerStats.active_second_item()
		elif event.is_action_pressed("slot3"):
			PlayerStats.active_third_item()
	
	if paused:
		
		if not toggleSettings:
			if event.is_action_pressed("ui_down"):
				if selected == OPTION_CONTINUE:
					selected = OPTION_SETTINGS
					$PauseOverlay/Label_switch.play()
					changed = true
				elif selected == OPTION_SETTINGS:
					selected = OPTION_QUIT
					$PauseOverlay/Label_switch.play()
					changed = true
			elif event.is_action_pressed("ui_up"):
				if selected == OPTION_QUIT:
					selected = OPTION_SETTINGS
					$PauseOverlay/Label_switch.play()
					changed = true
				elif selected == OPTION_SETTINGS:
					selected = OPTION_CONTINUE
					$PauseOverlay/Label_switch.play()
					changed = true
		
			#reset animace = if changed:, nejde ve funkci, idk why
			if selected == OPTION_CONTINUE:
				if changed:
					$PauseOverlay/AnimationPlayer.play("RESET")
					changed = false
					yield($PauseOverlay/AnimationPlayer, "animation_finished")
				$PauseOverlay/AnimationPlayer.play("selected_continue")
			elif selected == OPTION_SETTINGS:
				if changed:
					$PauseOverlay/AnimationPlayer.play("RESET")
					changed = false
					yield($PauseOverlay/AnimationPlayer, "animation_finished")
				$PauseOverlay/AnimationPlayer.play("selected_settings")
			elif selected == OPTION_QUIT:
				if changed:
					$PauseOverlay/AnimationPlayer.play("RESET")
					changed = false
					yield($PauseOverlay/AnimationPlayer, "animation_finished")
				$PauseOverlay/AnimationPlayer.play("selected_quit")
			
			if event.is_action_pressed("ui_accept"):
				match selected:
					OPTION_CONTINUE:
						self.paused = false
					OPTION_SETTINGS:
						self.toggleSettings = !toggleSettings
					OPTION_QUIT:
						get_tree().quit()
	#Setings
#	if toggleSettings:
#		if event.is_action_pressed("ui_cancel"):#tohle trigruje ale i unhandled input, takže to dá paused false
#			self.toggleSettings = !toggleSettings
#			scene_tree.set_input_as_handled()
	
	
	if event.is_action_released("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		self.paused = !paused #self = jde to přes setter
		scene_tree.set_input_as_handled()

#------------- SETTERY -------------#
func set_paused(value) -> void:
	changed = false
	paused = value
	scene_tree.paused = value
	pause_overlay.visible = value
	$Player_health.visible = !value
	$Inventory.visible = false
	$Hotbar.visible = !value
	$Shop.visible = false
	$Gold_label.visible = !value
	$PauseOverlay/AnimationPlayer.play("RESET")
	
	if value == true: #tady u pauzy, invu a v mainu hidden on ready
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func toggleInventory(value) -> void:
	toggleInvent = value
	$Inventory.visible = value
	$Inventory.initialize_inventory()
	if value == false:
		on_closed_inv_return_holding_item()
		emit_signal("inv_was_closed")
	if value == true:
		emit_signal("inv_was_opened")
	
	if value == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func toggleShop_(value) -> void:
	toggleShop = value
	$Shop.visible = value
#	$Inventory.visible = value
	toggleInventory(value)
	if value == false:
		on_closed_inv_return_holding_item()
	Globals.is_in_opened = value
#------------- SETTERY -------------#


#------------- HP BAR -------------#
func _on_PlayerStats_player_health_updated(health) -> void:
	player_health.value = health
	var hp = player_health.value / player_health.max_value * 100
	$Player_health/hp_text.text = "%s" % hp
	print(str(get_parent().name) + " hp updated: "+ str(health))

func _on_PlayerStats_player_max_health_updated(max_health) -> void:
	player_health.max_value = max_health
	print(str(get_parent().name) + " max hp updated: "+ str(max_health))
#------------- HP BAR -------------#

func gold_updated():
	Globals.golds = clamp(Globals.golds, 0, 99999)
	$Gold_label.text = "Golds: %s" % Globals.golds

func on_closed_inv_return_holding_item():
	if holding_item != null:
		var node = holding_item
		if toggleInvent == false:
			var empty_hb = PlayerStats.is_hotbar_empty()
			var empty_inv = PlayerStats.is_inventory_empty()

			if empty_inv or empty_hb:
				PlayerStats.add_item(holding_item.item_name, true)
				holding_item = null
			else:
				holding_item = null
			
			if get_node(node.name):
				get_node(node.name).remove_item() #funkce v item.gd



#-------------------------- LABEL CLICK --------------------------#
func _on_Label_continue_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		selected = OPTION_CONTINUE
		changed = true
		$PauseOverlay/Label_switch.play()
		self.paused = false
		$PauseOverlay/AnimationPlayer.play("RESET")

func _on_Label_settings_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		selected = OPTION_SETTINGS
		$PauseOverlay/Label_switch.play()
		changed = true
		self.toggleSettings = !toggleSettings

func _on_Label_quit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		selected = OPTION_QUIT
		changed = true
		$PauseOverlay/Label_switch.play()
		get_tree().quit()
#-------------------------- LABEL CLICK --------------------------#

#-------------------------- SETTINGS --------------------------#
func toggleSettings_(value):
	toggleSettings = value
	$PauseOverlay/Settings.visible = value
	$PauseOverlay/Right.visible = !value
	$PauseOverlay/CenterContainer.visible = !value


func _on_Settings_settings_label_back() -> void:
	self.toggleSettings = !toggleSettings
#-------------------------- SETTINGS --------------------------#


