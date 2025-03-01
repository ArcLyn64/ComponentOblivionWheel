@tool
class_name ComponentWheel
extends Control
######################
# region Export Vars
######################
## Press this button to update all components in the editor
@export var update_button:bool = false :
    set(v):
        if not Engine.is_editor_hint(): return
        update_all_components()
@export_group('Logic')
# @export var input_handler:WheelInput
# @export var puzzle_handler:WheelPuzzle
@export_group('Components')
@export var slices:WheelSlices
@export var segments:WheelSegments
@export var overlay:Control
@export var covers:WheelCovers
@export var selector:Control
#endregion

func update_all_components():
        for e in [slices, segments, overlay, covers, selector]:
            if e and 'update' in e and e.update is Callable: e.update()

func _ready() -> void:
    update_all_components()
