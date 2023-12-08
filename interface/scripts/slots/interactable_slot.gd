extends BaseSlot

func _on_send_button_pressed() -> void:
	get_tree().call_group("character_inventory", "add_item", _item)#adicionar item no inventario do personagem
	update_item("decrease")
	pass
