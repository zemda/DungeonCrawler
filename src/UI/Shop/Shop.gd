extends Node2D

const SlotClass = preload("res://src/UI/Inventory/Slot.gd")

onready var shop_slots = $ShopSlots
onready var slots = shop_slots.get_children()
var _is_item_bought = true

func _ready() -> void:
	assert(PlayerStats.connect("item_not_added", self, "is_item_bought") == 0)
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "slot_gui_input", [slots[i]])
		slots[i].slot_index = i #každému slotu přiřadí index, abychom při koupi jej dali do inv dictionary
		slots[i].slot_type = SlotClass.SlotType.SHOP #Nastavíme jaký to je slot, jestli hotbar/invent, nebo shop
		initialize_shop()



func _input(event: InputEvent) -> void:
	if Globals.is_in_opened == true:
		if event.is_action_pressed("shop_1"):
			get_tree().set_input_as_handled()
			if Globals.golds >= PlayerStats.shop[0][1]:
				buy_an_item(PlayerStats.shop[0][0], 0)
			elif Globals.golds < PlayerStats.shop[0][1]: 
					$Info.text = "You don't have enough gold."
					$Info.show()
					$Info_visibility.start()
		elif event.is_action_pressed("shop_2"):
			get_tree().set_input_as_handled()
			if Globals.golds >= PlayerStats.shop[1][1]:
				buy_an_item(PlayerStats.shop[1][0], 1)
			elif Globals.golds < PlayerStats.shop[1][1]: 
					$Info.text = "You don't have enough gold."
					$Info.show()
					$Info_visibility.start()
		elif event.is_action_pressed("shop_3"):
			get_tree().set_input_as_handled()
			if Globals.golds >= PlayerStats.shop[2][1]:
				buy_an_item(PlayerStats.shop[2][0], 2)
			elif Globals.golds < PlayerStats.shop[2][1]: 
					$Info.text = "You don't have enough gold."
					$Info.show()
					$Info_visibility.start()
		elif event.is_action_pressed("shop_4"):
			get_tree().set_input_as_handled()
			if Globals.golds >= PlayerStats.shop[3][1]:
				buy_an_item(PlayerStats.shop[3][0], 3)
			elif Globals.golds < PlayerStats.shop[3][1]: 
					$Info.text = "You don't have enough gold."
					$Info.show()
					$Info_visibility.start()
		elif event.is_action_pressed("shop_5"):
			get_tree().set_input_as_handled()
			if Globals.golds >= PlayerStats.shop[4][1]:
				buy_an_item(PlayerStats.shop[4][0], 4)
			elif Globals.golds < PlayerStats.shop[4][1]: 
					$Info.text = "You don't have enough gold."
					$Info.show()
					$Info_visibility.start()
#	0: ["Sword", 55, 8], #slot index, item name, item price
#	1: ["bow", 180, 8], 
#	2: ["spear", 90, 12],
#	3: ["hammer", 120, 18],
#	4: ["Health_potion", 20, 10],

func initialize_shop():
	slots = shop_slots.get_children()
	for i in range(slots.size()):
		if PlayerStats.shop.has(i):
			slots[i].initialize_item(PlayerStats.shop[i][0])

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed: #Pokud klikneme na slot a je v něm předmět
			if slot.item and Globals.golds >= PlayerStats.shop[slot.slot_index][1]: #Pokud máme dostatek goldů
				PlayerStats.add_item(slot.item.item_name, true) #Přidáme item do invu
				if _is_item_bought: #Pokud se předmět zakoupí, resp  v add_item se nevyšle signál o plném inventáři
					Globals.golds -= PlayerStats.shop[slot.slot_index][1] #odečíst goldy od ceny koupeného itemu
					Stats.emit_signal("gold_updated") #aktualizace goldů v UI
				else:
					$Info.text = "Full inventory."
					$Info.show()
					$Info_visibility.start()
			elif slot.item and Globals.golds < PlayerStats.shop[slot.slot_index][1]: 
					$Info.text = "You don't have enough gold."
					$Info.show()
					$Info_visibility.start()
	elif slot.item: #Pokud nad slot s itemem najedeme myší, zobrazí se informace - jména, cena, popis
		var _name = PlayerStats.shop[slot.slot_index][0]
		var _price = PlayerStats.shop[slot.slot_index][1]
		var _description = PlayerStats.shop[slot.slot_index][2]
		if _name == "Health_potion":
			$Description.text = "Item: %s" % _name + "\nPrice: %s" % _price + "\nHP: %s" % _description
			$Description.show()
			$Desc_visibility.start()
		else:
			$Description.text = "Item: %s" % _name + "\nPrice: %s" % _price + "\nDMG: %s" % _description
			$Description.show()
			$Desc_visibility.start()

func buy_an_item(item_name, slot_index):
	PlayerStats.add_item(item_name, true) #Přidáme item do invu
	if _is_item_bought: #Pokud se předmět zakoupí, resp  v add_item se nevyšle signál o plném inventáři
		Globals.golds -= PlayerStats.shop[slot_index][1] #odečíst goldy od ceny koupeného itemu
		Stats.emit_signal("gold_updated") #aktualizace goldů v UI
	else:
		$Info.text = "Full inventory."
		$Info.show()
		$Info_visibility.start()

func is_item_bought():
	_is_item_bought = false

func _on_Info_visibility_timeout() -> void:
	$Info.hide()


func _on_Desc_visibility_timeout() -> void:
	$Description.hide()
