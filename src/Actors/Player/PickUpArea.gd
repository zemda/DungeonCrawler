extends Area2D

var items_in_range = {}

func _on_PickUpArea_area_entered(area: Area2D) -> void:
	items_in_range[area] = area


func _on_PickUpArea_area_exited(area: Area2D) -> void:
	if items_in_range.has(area):
		items_in_range.erase(area)
