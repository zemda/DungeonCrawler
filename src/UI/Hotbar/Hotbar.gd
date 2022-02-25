extends Node2D

const SlotClass = preload("res://src/UI/Inventory/Slot.gd")

onready var active_item_label = $ColorRect/ActiveItemLabel
onready var hotbar_slots = $ColorRect/HotbarSlots
onready var slots = hotbar_slots.get_children()

var is_inv_opened = false

func _ready():
	assert(PlayerStats.connect("active_item_updated", self, "update_active_item_label") == 0)
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "slot_gui_input", [slots[i]]) #default signal gui_input, Emitted when the node receives an InputEvent.
		assert(PlayerStats.connect("active_item_updated", slots[i], "refresh_style") == 0)
		#když se to emitne, tak v slot.gd se spustí refresh_style, connectli jsme každý slot (slots[i])
		slots[i].slot_index = i #každému slotu přiřadím index, abychom pak mohli při přetahování itemů je jednoduše aktualizovat v PlayerStats v Inventory (dictionary)
		slots[i].slot_type = SlotClass.SlotType.HOTBAR
	initialize_hotbar() 
	update_active_item_label()


func initialize_hotbar():
	for i in range(slots.size()):
		if PlayerStats.hotbar.has(i):
			slots[i].initialize_item(PlayerStats.hotbar[i][0])


func slot_gui_input(event: InputEvent, slot: SlotClass):#default signal
	if is_inv_opened:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT && event.pressed: #pokud levým tl. táhneme item
				if find_parent("Player_UI").holding_item != null: #Krok 2: když už item držím a chci ho někam vložit
					if !slot.item: #vložit ten item co držím do volnýho slotu
						PlayerStats.add_item_to_an_empty_slot(find_parent("Player_UI").holding_item, slot, true)
						slot.putIntoSlot(find_parent("Player_UI").holding_item)
						find_parent("Player_UI").holding_item = null
					else: #Swapnout ten item co držím s itemem, co už ve slotu je
						if find_parent("Player_UI").holding_item.item_name != slot.item.item_name:
							swap_items(event, slot)
				elif slot.item: #Krok 1: prvně proběhne tohle, tzn vzetí itemu
					#Musí to být ale jako elif, jinak při swapování to blbne
					PlayerStats.remove_item(slot, true)
					find_parent("Player_UI").holding_item = slot.item
					slot.pickFromSlot()
					find_parent("Player_UI").holding_item.global_position = get_global_mouse_position() #insta pozice na myš
				update_active_item_label()


func swap_items(event: InputEvent, slot: SlotClass):
	PlayerStats.remove_item(slot, true)
	PlayerStats.add_item_to_an_empty_slot(find_parent("Player_UI").holding_item, slot, true) #aby se to aktulizovalo i v dictionary Invent
	var temp_item = slot.item
	slot.pickFromSlot()
	temp_item.global_position = event.global_position #když držím, ať je tam kde je myš
	slot.putIntoSlot(find_parent("Player_UI").holding_item)
	find_parent("Player_UI").holding_item = temp_item


func update_active_item_label():
	if slots[PlayerStats.active_item_slot].item != null:
		active_item_label.text = slots[PlayerStats.active_item_slot].item.item_name
	else:
		active_item_label.text = ""



func _on_Player_UI_inv_was_opened() -> void: #blby, ale měloi by jít
	is_inv_opened = true


func _on_Player_UI_inv_was_closed() -> void:
	is_inv_opened = false
