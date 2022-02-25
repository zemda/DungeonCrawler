extends Panel


var empty_texture = preload("res://assets/ui/inventory/Empty_slot_darker.png") #prazdnej
var default_texture = preload("res://assets/ui/inventory/Empty slot.png") #má item, ale není selectnuty
var selected_texture = preload("res://assets/ui/inventory/selected_slot.png")

var empty_style: StyleBoxTexture = null
var default_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null

var ItemClass = preload("res://src/UI/Inventory/Item.tscn")
var item = null
var slot_index
var slot_type

enum SlotType {
	HOTBAR = 0,
	INVENTORY,
	SHOP
}

func _ready() -> void:
	empty_style = StyleBoxTexture.new()
	default_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	empty_style.texture = empty_texture
	default_style.texture = default_texture
	selected_style.texture = selected_texture
	
	
	refresh_style()


func initialize_item(item_name):
	if item == null:
		item = ItemClass.instance()
		add_child(item)
		item.set_item(item_name)
	else:
		item.set_item(item_name)
	refresh_style()


func pickFromSlot():
	remove_child(item)
	var inventoryNode = find_parent("Player_UI")
	inventoryNode.add_child(item)
	item = null
	refresh_style()


func putIntoSlot(new_item):
	item = new_item
	item.position = Vector2.ZERO
	var inventoryNode = find_parent("Player_UI")
	inventoryNode.remove_child(item)
	add_child(item)
	refresh_style()


func remove_item_from_slot():
	remove_child(item)
	item.remove_item() #když se úplně maže z invu/hb, třeba při použití, musí se item vymazat, aby se neleakovala instance,
	item = null
	refresh_style()

func refresh_style():
	if SlotType.HOTBAR == slot_type and PlayerStats.active_item_slot == slot_index:
		set("custom_styles/panel", selected_style)
	elif item == null:
		set("custom_styles/panel", empty_style)
	else:
		set("custom_styles/panel", default_style)
