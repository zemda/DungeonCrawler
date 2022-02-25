extends Node2D

const SlotClass = preload("res://src/UI/Inventory/Slot.gd")
onready var inventory_slots = $CenterContainer/GridContainer

func _ready():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "slot_gui_input", [slots[i]])
		slots[i].slot_index = i #každému slotu přiřadí index, abychom pak mohli při přetahování itemů je jednoduše aktualizovat v PlayerStats v Inventory (dictionary)
		slots[i].slot_type = SlotClass.SlotType.INVENTORY #Nastavíme jaký to je slot, jestli hotbar/invent
	initialize_inventory() 
	
	var trashbin = $TrashBin
	trashbin.connect("gui_input", self, "delte_item_from_inv")

func initialize_inventory():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if PlayerStats.inventory.has(i):
			slots[i].initialize_item(PlayerStats.inventory[i][0])
#			když změníme item v invu, tak aby se nastavila textura itemu/slotu

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed: #pokud levým tl. táhneme item
			if find_parent("Player_UI").holding_item != null: #Krok 2: když už item držím a chci ho někam vložit
				if !slot.item: #vložit ten item co držím do volnýho slotu
					PlayerStats.add_item_to_an_empty_slot(find_parent("Player_UI").holding_item, slot)
					slot.putIntoSlot(find_parent("Player_UI").holding_item)
					find_parent("Player_UI").holding_item = null
				else: #Swapnout ten item co držím s itemem, co už ve slotu je
					if find_parent("Player_UI").holding_item.item_name != slot.item.item_name:
						swap_items(event, slot)
			elif slot.item: #Krok 1: prvně proběhne tohle, tzn vzetí itemu
				#Musí to být ale jako elif, jinak při swapování to blbne
				PlayerStats.remove_item(slot)
				find_parent("Player_UI").holding_item = slot.item
				slot.pickFromSlot()
				find_parent("Player_UI").holding_item.global_position = get_global_mouse_position() #insta pozice na myš


func _input(event: InputEvent) -> void: #updatujeme pozici itemu tam, kde je myš
	if find_parent("Player_UI").holding_item:
		find_parent("Player_UI").holding_item.global_position = get_global_mouse_position()


func swap_items(event: InputEvent, slot: SlotClass):
	PlayerStats.remove_item(slot)
	PlayerStats.add_item_to_an_empty_slot(find_parent("Player_UI").holding_item, slot) #aby se to aktulizovalo i v dictionary Invent
	var temp_item = slot.item
	slot.pickFromSlot()
	temp_item.global_position = event.global_position #když držím, ať je tam kde je myš
	slot.putIntoSlot(find_parent("Player_UI").holding_item)
	find_parent("Player_UI").holding_item = temp_item

func delte_item_from_inv(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if find_parent("Player_UI").holding_item != null:
				var node = find_parent("Player_UI").holding_item
				find_parent("Player_UI").holding_item = null
				if find_parent("Player_UI").get_node(node.name):
					find_parent("Player_UI").get_node(node.name).remove_item()
