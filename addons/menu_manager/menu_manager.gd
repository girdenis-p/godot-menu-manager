@tool
## Children OpenActions act as root menus that can be opened and closed from script.
class_name MenuManager
extends Control

## Emitted when a request action is pressed
signal action_requested(action : StringName)

## Menu to be displayed initially
@export var main_menu : OpenAction:
	set(mm):
		main_menu = mm
		update_configuration_warnings()

var menus := {}

var _stack : Array[NodePath] = []

@onready var back_button = Button.new()


func _get_configuration_warnings() -> PackedStringArray:
	if main_menu == null:
		return ["No main menu selected, nothing will be displayed when tree is entered."]
	elif not is_ancestor_of(main_menu):
		return ["Main menu must be a child of the MenuManager."]
	return []


func _append_to_stack(menu : NodePath) -> void:
	if not _stack.is_empty():
		menus[_stack.back()].hide()
		back_button.show()
	_stack.append(menu)
	menus[_stack.back()].show()


func _pop_stack() -> void:
	if not _stack.is_empty():
		menus[_stack.back()].hide()
		_stack.pop_back()
		
		if _stack.size() <= 1:
			back_button.hide()
		
		if not _stack.is_empty():
			menus[_stack.back()].show()


func _clear_stack() -> void:
	if not _stack.is_empty():
		menus[_stack.back()].hide()
		_stack.clear()
	
	back_button.hide()


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
		elif child is RequestAction:
			open_action._buttons[child.name].connect("pressed", func ():
				child.requested.emit()
				if child.action != "":
					action_requested.emit(child.action)
				else:
					action_requested.emit(child.name.to_lower())
			)
		elif child is CopyOpenAction:
			open_action._buttons[child.name].connect("pressed", func():
				_append_to_stack(get_path_to(child.open_action))
			)


func _ready() -> void:
	back_button.connect("pressed", _pop_stack)
	back_button.text = "<"
	back_button.anchor_left = 0.05
	back_button.anchor_right = 0.15
	back_button.anchor_top = 0.05
	back_button.anchor_bottom = 0.15
	add_child(back_button)
	back_button.hide()
	
	for child in get_children():
		if child is OpenAction:
			_generate_open_action_menu(child)
	
	if main_menu != null:
		_append_to_stack(get_path_to(main_menu))


func open(menu : OpenAction) -> void:
	_clear_stack()
	_append_to_stack(get_path_to(menu))


func close() -> void:
	_clear_stack()
