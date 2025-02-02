@tool
## Defines the structure of a menu. When this appears as the child on another OpenAction
## then this represents a button that navigates to menu generated from child actions.
class_name OpenAction
extends BaseMenuAction

enum LAYOUT {
	## The hint (if used) and buttons take up an equal amount of space and are ordered vertically.
	PORTRAIT = 0,
	## The hint (if used) takes up the majority of the upper part of the screen and buttons are ordered vertically below it.
	VERTICAL_LANDSCAPE = 1,
	## The hint (if used) takes up the majority of the screen and the buttons are ordered horizontally below it.
	HORIZONTAL_LANDSCAPE = 2, 
	## Ordering is determined by the first parent not set to inherit. If no such parent exists, then this defaults to Portrait.
	INHERIT = 3}
@export var layout := LAYOUT.INHERIT

@export var theme : Theme

@export_group("Hint", "hint_")
## Determines whether a text label should be rendered with the menu
@export var hint_display_hint := true:
	set(b):
		hint_display_hint = b
		notify_property_list_changed()

var hint := ""

var _buttons := {}

func _get_property_list() -> Array[Dictionary]:
	if hint_display_hint:
		return [{
			"name" : "hint_text",
			"type" : TYPE_STRING,
			"usage" : 4102
		}]
	
	return []


func _property_can_revert(property: StringName) -> bool:
	if property == "hint_text":
		return true
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property == "hint_text":
		return hint
	return null


func _get(property: StringName) -> Variant:
	if property == "hint_text":
		return hint
	return null


func _set(property: StringName, value: Variant) -> bool:
	if property == "hint_text":
		hint = value
		return true
	return false


func _get_parent_layout() -> LAYOUT:
	var parent = get_parent()
	if parent is OpenAction:
		if parent.layout == LAYOUT.INHERIT:
			return parent._get_parent_layout()
		else:
			return parent.layout
	# Default is Portrait
	return LAYOUT.PORTRAIT


func _get_parent_theme() -> Theme:
	var parent = get_parent()
	if parent is OpenAction:
		if parent.theme == null:
			return parent._get_parent_theme()
		else:
			return parent.theme
	elif parent is MenuManager:
		return parent.theme
	return theme


func _generate_menu() -> Control:
	var base = Control.new()
	# Pass theme through inheritance where applicable
	if theme == null:
		base.theme = _get_parent_theme()
	else:
		base.theme = theme
	# Set anchors to match size of parent menu manager
	base.anchor_left = 0
	base.anchor_right = 1
	base.anchor_top = 0
	base.anchor_bottom = 1
	# Ignore mouse
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Determine layout to use
	var layout_used = layout
	if layout == LAYOUT.INHERIT:
		layout_used = _get_parent_layout()
	# Generate hint if applicable
	if hint_display_hint:
		var hint_label = Label.new()
		hint_label.text = hint
		hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if layout_used == LAYOUT.VERTICAL_LANDSCAPE else HORIZONTAL_ALIGNMENT_CENTER
		base.add_child(hint_label)
		
		match layout_used:
			LAYOUT.PORTRAIT:
				var unit_height = 1.0 / (get_child_count() + 2.0 + (1.0 if hint_display_hint else 0.0))
				hint_label.anchor_top = 1.05 * unit_height
				hint_label.anchor_bottom = 1.95 * unit_height
				hint_label.anchor_left = 1.0 / 3.0
				hint_label.anchor_right = 2.0 / 3.0
			LAYOUT.VERTICAL_LANDSCAPE:
				hint_label.anchor_top = 0.05
				hint_label.anchor_bottom = 0.4
				hint_label.anchor_left = 0.05
				hint_label.anchor_right = 0.75
			LAYOUT.HORIZONTAL_LANDSCAPE:
				hint_label.anchor_top = 0.05
				hint_label.anchor_bottom = 0.75
				hint_label.anchor_left = 0.25
				hint_label.anchor_right = 0.75
	
	var button_idx = 0
	
	for child in get_children():
		if child is BaseMenuAction:
			var action_button = Button.new()
			action_button.text = child.name
			_buttons[child.name] = action_button
			base.add_child(action_button)
			
			match layout_used:
				LAYOUT.PORTRAIT:
					var unit_height = 1.0 / (get_child_count() + 2.0 + (1.0 if hint_display_hint else 0.0))
					action_button.anchor_top = unit_height * (1.05 + (button_idx + (1.0 if hint_display_hint else 0.0)))
					action_button.anchor_bottom = unit_height * (1.95 + (button_idx + (1.0 if hint_display_hint else 0.0)))
					action_button.anchor_left = 1.0 / 3.0
					action_button.anchor_right = 2.0 / 3.0
				LAYOUT.VERTICAL_LANDSCAPE:
					var unit_height = 1.0 / (get_child_count() + 2.0)
					var vertical_anchor_begin = 0.4 if hint_display_hint else 0.0
					var vertical_anchor_scalar = 0.6 if hint_display_hint else 1.0
					action_button.anchor_top = vertical_anchor_begin + vertical_anchor_scalar * unit_height * (1.05 + button_idx)
					action_button.anchor_bottom = vertical_anchor_begin + vertical_anchor_scalar * unit_height * (1.95 + button_idx)
					action_button.anchor_left = 0.05
					action_button.anchor_right = 0.45
				LAYOUT.HORIZONTAL_LANDSCAPE:
					var unit_width = 1.0 / (get_child_count() + 2.0)
					action_button.anchor_top = 0.8
					action_button.anchor_bottom = 0.95
					action_button.anchor_left = unit_width * (1.05 + button_idx)
					action_button.anchor_right = unit_width * (1.95 + button_idx)
			
			button_idx += 1
	
	return base
