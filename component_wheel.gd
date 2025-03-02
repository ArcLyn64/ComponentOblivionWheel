@tool
class_name ComponentWheel
extends Control

signal new_segment_selected()
signal new_segment_chosen(selection_data:WheelSelectionData)
signal puzzle_finished()
# rotation started/ended are found under the slices component

######################
# region Export Vars
######################
## Press this button to update all components in the editor
@export var update_button:bool = false :
    set(v):
        if not Engine.is_editor_hint(): return
        update_all_components()

@export_group('Logic')
@export var disable_selection_during_animation:bool = false
@export var disable_selected_segments:bool = true
# @export var input_handler:WheelInput
# @export var puzzle_handler:WheelPuzzle

@export_group('Component Sync')
@export var radius:float = 100 :
    set(v):
        radius = max(0, v)
        _sync_radius()
@export var wheel_sections:int = 4 :
    set(v):
        wheel_sections = max(0, v)
        _sync_wheel_sections()

@export_group('Components')
@export var slices:WheelSlices
@export var segments:WheelSegments
@export var overlay:Control
@export var covers:WheelCovers
@export var selector:Control # should have a selected_index:int property
#endregion

func _ready() -> void:
    assert(slices, 'wheel is missing slices!')
    assert(segments, 'wheel is missing segments!')
    assert(overlay, 'wheel is missing an overlay!')
    assert(covers, 'wheel is missing covers!')
    assert(selector, 'wheel is missing a selector!')
    assert('selected_index' in selector and selector.selected_index is int, 'selector is not keeping track of selections!')
    update_all_components()

#####################
# region Value Sync
#####################

func _sync_radius():
    if slices: slices.maximum_radius = radius
    if segments: segments.radius = radius
    if overlay and 'radius' in overlay: overlay.radius = radius
    if covers: covers.radius = radius
    if selector and 'radius' in selector: selector.radius = radius

func _sync_wheel_sections():
    if slices: slices.num_slices = wheel_sections
    if segments: segments.num_segments = wheel_sections
    if overlay and 'num_borders' in overlay: overlay.num_borders = wheel_sections
    if covers: covers.num_covers = wheel_sections
    if selector and 'num_positions' in selector: selector.num_positions = wheel_sections

func update_all_components():
        for e in [slices, segments, overlay, covers, selector]:
            # print_debug(e and 'update' in e and e.update is Callable)
            if e and 'update' in e and e.update is Callable: e.update()
# endregion

######################
# region Wheely Info
######################

func is_selected_index_selectable() -> bool: return covers.is_index_selectable(selector.selected_index)

func is_selector_active() -> bool: return selector.visible

func get_selected_index() -> int: return selector.selected_index

func is_rotating() -> bool: return slices.is_rotating()

func get_selection_data() -> WheelSelectionData:
    if not is_selector_active(): return null
    var selected_index = get_selected_index()

    var selection_data = WheelSelectionData.new()
    selection_data.selection_index = get_selected_index()
    selection_data.slice_position = slices.position_index
    selection_data.base_value = segments.get_value_at(selected_index)
    selection_data.multiplier = slices.get_multiplier_at(selected_index)
    selection_data.total_value = selection_data.base_value * selection_data.multiplier
    
    return selection_data
    
func num_remaining_selectable_segments() -> int:
    var selectable = covers.num_covers
    for cover_enabled in covers.show_cover:
        if cover_enabled: selectable -= 1
    return selectable

func is_no_selectable_segments() -> bool: return num_remaining_selectable_segments() <= 0

#########################
# region Wheel Mutators
#########################

## returns true if the selection successfully went through, false otherwise.
func confirm_selection() -> bool:
    if disable_selection_during_animation and is_rotating(): return false
    if not is_selector_active() or not is_selected_index_selectable(): return false
    var selection_data = get_selection_data()
    if not selection_data: return false
    if disable_selected_segments: covers.disable_cover(get_selected_index())
    new_segment_chosen.emit(selection_data)
    return true

func enable_all_segments(): covers.disable_all_covers()

func disable_all_segments(): covers.enable_all_covers()

func reset(shuffle_values_:bool = true, shuffle_multipliers_:bool = true):
    if shuffle_values_: segments.shuffle_values()
    if shuffle_multipliers_: slices.shuffle_multipliers()
    enable_all_segments()

## Useful for when the multiplier value is being used for display purposes
func zero_all_multipliers():
    slices.values = [0]
    slices.update()

# endregion