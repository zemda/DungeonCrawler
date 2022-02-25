extends Node2D

var item_name

func set_item(name):
	item_name = name
	$TextureRect.texture = load("res://src/Objects/Pickable_items/Item_icons/" + item_name + ".png")

func remove_item():
	queue_free()
