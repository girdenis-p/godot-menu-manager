@tool
extends MenuManager


func _on_action_requested(action: StringName) -> void:
	if action == "exit":
		get_tree().quit()


func _on_start_requested() -> void:
	open($Game)


func _on_back_to_main_menu_requested() -> void:
	open($Main)


func _on_fireball_requested() -> void:
	close()
