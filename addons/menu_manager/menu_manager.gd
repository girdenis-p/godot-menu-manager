@tool
## Children OpenActions act as root menus that can be opened and closed from script.
class_name MenuManager
extends Control

## Menu to be displayed initially
@export var main_menu : OpenAction:
	set(mm):
		main_menu = mm
		update_configuration_warnings()

var menus := {}

var _stack : Array[NodePath] = []


func _get_configuration_warnings() -> PackedStringArray:
	if main_menu == null:
		return ["No main menu selected, nothing will be displayed when tree is entered."]
	elif not is_ancestor_of(main_menu):
		return ["Main menu must be a child of the MenuManager."]
	return []


func _append_to_stack(menu : NodePath) -> void:
	if not _stack.is_empty():
		menus[_stack.back()].hide()
	_stack.append(menu)
	menus[_stack.back()].show()


func _generate_open_action_menu(open_action : OpenAction) -> void:
	var menu = open_action._generate_menu()
	menus[get_path_to(open_action)] = menu
	add_child(menu)
	menu.hide()
	_generate_menu_behaviour(open_action)
	

func _generate_menu_behaviour(open_action : OpenAction) -> void:
	for child in open_action.get_children():
		if child is OpenAction:
			_generate_open_action_menu(child)
			open_action._buttons[child.name].connect("pressed", func ():
				_append_to_stack(get_path_to(child))
			)


func _ready() -> void:
	for child in get_children():
		if child is OpenAction:
			_generate_open_action_menu(child)
	
	if main_menu != null:
		_append_to_stack(get_path_to(main_menu))
