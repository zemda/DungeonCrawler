extends "res://src/AutoLoad/Stats.gd"
#Ne až tak stats, ale spíš inv, stats, vše nějak tak

signal active_item_updated
signal item_not_added

const SlotClass = preload("res://src/UI/Inventory/Slot.gd")
const ItemClass = preload("res://src/UI/Inventory/Item.gd")
const INV_SLOTS = 6
const HOTBAR_SLOTS = 3

#onready var hotbarSlots = get_node("/root/Map/UI/Player_UI/Hotbar/ColorRect/HotbarSlots") #blbý, ale pro teď dobrý
#onready var HBslots = hotbarSlots.get_children()
onready var hotbarSlots #TOHLE ASI NĚJAK UPRAVIT, BLBĚ UDĚLANÝ KVŮLI START SCREENU
onready var HBslots     #TOHLE ASI NĚJAK UPRAVIT, BLBĚ UDĚLANÝ KVŮLI START SCREENU

var active_item_slot = 0 #aktivní slot hotbaru, index
var active_item = "Empty" #jméno aktivního hotbar slotu, kvůli match v Player scriptu


#Bacha na velke/male pismena!!
var inventory = { #dictionary, každý jakoby slot je array
#	0: ["Item_name"] -> slot index, item name
	0: ["Health_potion"], #jen ted, at tam něco je
	1: ["Health_potion"],
	2: ["Health_potion"],
	3: ["hammer"],
}

var hotbar = {
	0: ["Sword"], #jen ted, at tam něco je
	1: ["bow"], 
	2: ["spear"]
}

var shop = {
#	x: [0, 1, 2]
#	x: ["name", price, dmg/hp]
	0: ["Sword", 55, 8], #slot index, item name, item price, popis (dmg/hp) přidat ještě množství
	1: ["bow", 180, 8], 
	2: ["spear", 90, 12],
	3: ["hammer", 120, 18],
	4: ["Health_potion", 20, 10],
}


func _init() -> void:
	assert(Globals.connect("start_game", self, "game_started") == 0)


func _ready() -> void:
	PlayerStats.emit_signal("player_max_health_updated", max_health)
	PlayerStats.emit_signal("player_health_updated", health)
	
	inventory.clear()
	hotbar.clear()
	hotbar[0] = ["Sword"]
	
	if hotbar.has(active_item_slot):
		active_item = hotbar[active_item_slot][0] #hotbar[aktivní_slot][name]
	else:
		 active_item = "Empty"


func is_inventory_empty():
	var is_inv_empty = false
	for i in range(INV_SLOTS): #přidat item do volného slotu
		if inventory.has(i) == false:
			is_inv_empty = true
			return is_inv_empty#return true
	return is_inv_empty #return false

func is_hotbar_empty(): 
	var is_hb_empty = false
	for i in range(HOTBAR_SLOTS):
		if hotbar.has(i) == false:
			is_hb_empty = true
			return is_hb_empty
	return is_hb_empty

#před volání add_item u itemu vyvolat check if is empty, bcs po add_item volám queue free
func add_item(item_name, is_hotbar: bool = false):
	
	#Předělat lépe mby
	
	var is_item_addable = false
	var is_hb_empty = false
	
	if is_hotbar:
		if is_hotbar_empty():
			is_hb_empty = true
			is_item_addable = true
		elif is_inventory_empty():
			is_item_addable = true
	else:
		if is_inventory_empty():
			is_item_addable = true
	
	
	if not is_item_addable: #if false
		emit_signal("item_not_added")
		print("item_not_added")
		return
	
	
	#debilně, udělat to lépe
	if is_hotbar and is_hb_empty: #pokud je někde místo v hb a voláme jej, vložíme item do hb, jinak do invu
		for i in range(HOTBAR_SLOTS):
			if hotbar.has(i) == false:
				hotbar[i] = [item_name]
				update_hotbar_slot_visualy(i, hotbar[i][0])
				return
	else: #pokud není místo v hb, nebo ani nevoláme hb, přidáme do invu
#		for item in inventory:
#			if inventory[item][0] == item_name: #check jestli už ten item máme, tak něco -> u shopu aby se nekoupil
#				#třeba později aby se nevzal, nebo vzal, ale vyhodil ten druhej, nebo stackování
#				pass
		
		for i in range(INV_SLOTS): #přidat item do volného slotu
			if inventory.has(i) == false: #tzn když je prázdnej, tak tam dát ten item
				inventory[i] = [item_name]
				update_slot_visualy(i, inventory[i][0]) #inventory[kolikatej_slot][první_atribut=jmeno]
				return


func update_slot_visualy(slot_index, item_name): #aktualizace slotu, když do něj něco vložíme a máme otevřenej inv
	var slot = get_tree().root.get_node("/root/Map/UI/Player_UI/Inventory/CenterContainer/GridContainer/Slot" + str(slot_index + 1)) #slot index je od 0, ale sloty máme pojmenovaný od 1
	slot.initialize_item(item_name)
	#šlo by jednoduše initialize_inventory při přidání itemu, ale zbytečně to checkuje a reloaduje všechny sloty

func update_hotbar_slot_visualy(slot_index, item_name):
	var slot = get_tree().root.get_node("/root/Map/UI/Player_UI/Hotbar/ColorRect/HotbarSlots/Slot" + str(slot_index + 1)) #chce to lepší cestu, než napevno - cuz může být jiné jméno mapy - pokud to nebudu generovat nějak
	slot.initialize_item(item_name)
	
	#Zajišťuje, abych hned po smazání itemu z hb slotu a přidání nového jej mohl hned použít, bez switchování, nebo swapu
	if hotbar.has(active_item_slot): #hned po přidání itemu do hotbaru aktualizovat aktivní item
		active_item = hotbar[active_item_slot][0]
	else:
		 active_item = "Empty"



func add_item_to_an_empty_slot(item: ItemClass, slot: SlotClass, is_hotbar: bool = false): #při swapování
	if is_hotbar: #když se přidává do hb - Hotbar.gd
		hotbar[slot.slot_index] = [item.item_name]
		
		if hotbar.has(active_item_slot): #hned po přidání itemu do hotbaru aktualizovat aktivní item
			active_item = hotbar[active_item_slot][0]
		else:
			 active_item = "Empty"
	else: #když se přidává do invu - Inventory.gd
		inventory[slot.slot_index] = [item.item_name]


func remove_item(slot: SlotClass, is_hotbar: bool = false):
	if is_hotbar:
		hotbar.erase(slot.slot_index)
		if hotbar.has(active_item_slot): #hned po smazání itemu do hotbaru aktualizovat aktivní item
			active_item = hotbar[active_item_slot][0]
		else:
			 active_item = "Empty"
	else:
		inventory.erase(slot.slot_index)


func active_next_item():
	active_item_slot = (active_item_slot + 1) % HOTBAR_SLOTS #zpět na začátek, když jsme na posledním slotu, modulo
	emit_signal("active_item_updated")
	if hotbar.has(active_item_slot):
		active_item = hotbar[active_item_slot][0]
	else:
		 active_item = "Empty"

func active_prev_item():
	if active_item_slot == 0:
		active_item_slot = HOTBAR_SLOTS - 1
	else:
		active_item_slot -= 1
	emit_signal("active_item_updated")
	if hotbar.has(active_item_slot): #jestli neni aktivní index prázdný, tak do active_item dáme jméno kvůli match v Player.gd
		active_item = hotbar[active_item_slot][0]
	else:
		 active_item = "Empty"


func active_first_item():
	active_item_slot = 0
	emit_signal("active_item_updated")
	if hotbar.has(active_item_slot):
		active_item = hotbar[active_item_slot][0]
	else:
		 active_item = "Empty"

func active_second_item():
	active_item_slot = 1
	emit_signal("active_item_updated")
	if hotbar.has(active_item_slot):
		active_item = hotbar[active_item_slot][0]
	else:
		 active_item = "Empty"

func active_third_item():
	active_item_slot = 2
	emit_signal("active_item_updated")
	if hotbar.has(active_item_slot):
		active_item = hotbar[active_item_slot][0]
	else:
		 active_item = "Empty"


func remove_used_item(): #hotbar used item remove
	remove_item(HBslots[active_item_slot], true) #smaže se z dictionary
	HBslots[active_item_slot].remove_item_from_slot() #smazat ten item ze slotu, když už není v dictionary
	emit_signal("active_item_updated")
	if hotbar.has(active_item_slot): #kdyby nahodou tam něco bylo, už zde asi nemusí být, když to je v remove_item
		active_item = hotbar[active_item_slot][0]
	else:
		active_item = "Empty"

func game_started():#TOHLE ASI NĚJAK UPRAVIT, BLBĚ UDĚLANÝ KVŮLI START SCREENU
	hotbarSlots = get_node("/root/Map/UI/Player_UI/Hotbar/ColorRect/HotbarSlots") #blbý, ale pro teď dobrý
#	get_tree().get_root().find_node("HotbarSlots") ?? 
	HBslots = hotbarSlots.get_children()

func retry_game():
	inventory.clear()
	hotbar.clear()
	emit_signal("active_item_updated")
	hotbar[0] = ["Sword"]
	active_item = hotbar[0][0]
	
