@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("BaseMenuAction", "Node", preload("base_menu_action.gd"), preload("action.svg"))
	add_custom_type("OpenAction", "BaseMenuAction", preload("open_action.gd"), preload("open_action.svg"))
	add_custom_type("CopyOpenAction", "BaseMenuAction", preload("copy_open_action.gd"), preload("open_action.svg"))
	add_custom_type("RequestAction", "BaseMenuAction", preload("request_action.gd"), preload("action.svg"))
	add_custom_type("MenuManager", "Control", preload("menu_manager.gd"), preload("menu_manager.svg"))


func _exit_tree() -> void:
	remove_custom_type("MenuManager")
	remove_custom_type("RequestAction")
	remove_custom_type("CopyOpenAction")
	remove_custom_type("OpenAction")
	remove_custom_type("BaseMenuAction")
