@tool
## As the child of an OpenAction, generates a button that emits a signal in the ancestor MenuManager
class_name RequestAction
extends BaseMenuAction

## Emitted when corresponding button for this action is pressed
signal requested

@export var action : StringName
