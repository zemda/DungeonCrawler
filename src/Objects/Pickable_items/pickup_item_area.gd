extends Area2D

var player = null
var being_picked_up = false
var _is_item_added = true #kvůli signálu, když už item přidávám, ale třeba z ničeho nic by byl inv full
var is_item_picked = false #kvůli hráči, aby se item nemazal z items in range dictionary v func _input
var motion = Vector2.ZERO


func _ready() -> void:
# warning-ignore:return_value_discarded
	PlayerStats.connect("item_not_added", self, "is_item_added")

func _physics_process(delta: float) -> void:
	if being_picked_up:
		var empty_hb = PlayerStats.is_hotbar_empty()
		var empty_inv = PlayerStats.is_inventory_empty()
	
		if empty_inv or empty_hb: #pokud je prázdnej inv nebo hb, tak pohyb k hráči a šup do invu
			var direction = global_position.direction_to(player.global_position)
			motion += direction * 200
			motion = motion.clamped(300) #200 akcelerace, 300 top speed
		
			var distance = global_position.distance_to(player.global_position)
			if distance < 5: #když už je to dostatečně blízko hráče, přidá se do invu
				PlayerStats.add_item(get_parent().item_name, true) #item name máme přímo v item scriptu (třeba item_HealthPotion), true, že to chceme do hotbaru pokud je místo
				if _is_item_added: #znovu, pro jistotu, cuz kdo ví co se může stát
					is_item_picked = true
					get_parent().queue_free() #smaže to parenta, takže celej item ze země
				else: #plnej inv, tak zrušíme sebrání itemu
					is_item_picked = false
					being_picked_up = false
					motion = motion.move_toward(Vector2.ZERO, 1000)
					
			motion = get_parent().move_and_slide(motion)#, Vector2.UP) #get parent, cuz chceme pohyb itemu
		else: #není místo
			is_item_picked = false
			being_picked_up = false


func pick_up_item(area):
	player = area
	being_picked_up = true


func is_picked_up(): #kvůli hráči, viz popis u is_item_picked
	return is_item_picked


func is_item_added():
	_is_item_added = false
