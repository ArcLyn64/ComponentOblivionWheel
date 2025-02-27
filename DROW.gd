@tool
class_name DROW
extends Control

#region Enums, Alias & Const
enum TweenType { 
    TRANS_LINEAR,   ## linear animation.
    TRANS_SINE,     ## sine animation.
    TRANS_QUINT,    ## quint animation.
    TRANS_QUART,    ## quart animation.
    TRANS_QUAD,     ## quad animation.
    TRANS_EXPO,     ## expo animation.
    TRANS_ELASTIC,  ## elastic animation.
    TRANS_CUBIC,    ## cubic animation.
    TRANS_CIRC,     ## circ animation.
    TRANS_BOUNCE,   ## bounce animation.
    TRANS_BACK,     ## back animation.
    TRANS_SPRING,   ## spring animation.
}

enum EaseType {
    EASE_IN,        ## Ease the beginning of the animation
    EASE_OUT,       ## Ease the ending of the animation
    EASE_IN_OUT,    ## Ease both ends of the animation
    EASE_OUT_IN,    ## Ease the middle of the animation
}

const DROW_CLICK_ACTION = 'DROW_wheel_click'

## alias util function
func wrap_index(length, index) -> int: return WheelUtil.wrap_index(length, index)
#endregion


#region Signals
signal new_segment_selected()
signal new_segment_chosen(selection_data:WheelSelectionData)
signal rotation_started()
signal rotation_finished()
# you have to call puzzle_finished() to check intentionally with this wheel...
signal node_on_border() # used for connected node area detection
#endregion

#region Exports
@export_group('State')
@export var selected_index:int = 0 :
    set(v):
        if selector:
            selector.selector_index = wrap_index(v, get_num_segments())
            if selector_active:
                new_segment_selected.emit()
    get():
        if selector: return selector.selector_index
        else: return 0
@export var slice_position:int = 0 :
    set(v):
        slice_position = wrap_index(v, get_num_segments())
        snap_gimbal_to_valid_angle()
@export var selector_active:bool = true:
    set(v):
        if selector: selector.visible = v
    get():
        if selector: return selector.visible
        else: return false

@export_group('Input')
## all external input disabled
@export var disable_all_input:bool = false
## disables selection while the wheel is animating
@export var disable_selection_during_animation:bool = false
## allows the player to point and click options on the wheel
@export var enable_mouse_input:bool = true
## disables segments when they are selected
@export var disable_selected_segments:bool = true
## automatically rotate segments on selection
@export var rotate_on_selection:bool = true
## use body/area segment area detection to select segments
## this should be either a body or area2D (to be compatable w/area detector signals)
@export var node_as_selector:Node2D = null

@export_group("Overlay and Selector Appearance")
@export var overlay_color:Color = Color.WHITE :
    set(v):
        if wheel_overlay: wheel_overlay.overlay_color = v
    get():
        if wheel_overlay: return wheel_overlay.overlay_color
        else: return Color.WHITE
@export var outer_border_thickness:float = 5.0 :
    set(v):
        if wheel_overlay: wheel_overlay.outer_border_thickness = v
        if selector: selector.outer_border_thickness = v
        set_custom_minimum_size(Vector2.ONE * ((2 * radius) + (outer_border_thickness)))
    get():
        if wheel_overlay: return wheel_overlay.outer_border_thickness
        else: return 0
@export var outer_border_texture:GradientTexture2D :
    set(v):
        if wheel_overlay: wheel_overlay.outer_border_texture = v
    get():
        if wheel_overlay: return wheel_overlay.outer_border_texture
        else: return null
@export var inner_border_thickness:float = 10.0 :
    set(v):
        if wheel_overlay: wheel_overlay.inner_border_thickness = v
        if selector: selector.inner_border_thickness = v
    get():
        if wheel_overlay: return wheel_overlay.inner_border_thickness
        else: return 0
@export var selector_color:Color = Color.DEEP_SKY_BLUE :
    set(v):
        if selector: selector.color = v
    get():
        if selector: return selector.color
        else: return Color.DEEP_SKY_BLUE
@export var selector_thickness:float = 10.0:
    set(v):
        if selector: selector.selector_thickness = v
    get():
        if selector: return selector.selector_thickness
        else: return 0.0
@export var cover_color:Color = Color('#3b3b3bc0') :
    set(v):
        if covers: covers.color = v
    get():
        if covers: return covers.color
        else: return Color('#3b3b3bc0')
@export var cover_texture:GradientTexture1D :
    set(v):
        if covers: covers.texture = v
    get():
        if covers and covers.texture is GradientTexture1D: return covers.texture
        else: return null

@export_group('Size and Rendering Settings')
@export var radius:float = 100.0 :
    set(v):
        radius = v
        _sync_radius()
@export var slice_fidelity:int = 20 :
    set(v):
        if slices: slices.slice_fidelity = v
    get():
        if slices: return slices.slice_fidelity
        else: return 2
@export var segment_fidelity:int = 20 :
    set(v):
        if segments: segments.segment_fidelity = v
    get():
        if segments: return segments.segment_fidelity
        else: return 2
@export var outer_border_fidelity:int = 60 :
    set(v):
        if wheel_overlay: wheel_overlay.outer_border_fidelity = v
    get():
        if wheel_overlay: return wheel_overlay.outer_border_fidelity
        else: return 0
@export var selector_fidelity:int = 20 :
    set(v):
        if selector: selector.fidelity = v
    get():
        if selector: return selector.fidelity
        else: return 2
@export var hitbox_fidelity:int = 5 :
    set(v):
        if slices: slices.hitbox_fidelity = v
        if segments: segments.hitbox_fidelity = v
    get():
        if slices: return slices.hitbox_fidelity
        elif segments: return segments.hitbox_fidelity
        else: return 2
@export var cover_fidelity:int = 20 :
    set(v):
        if covers: covers.fidelity = v
    get():
        if covers: return covers.fidelity
        else: return 2

@export_group('Animation')
@export var transition:TweenType = TweenType.TRANS_CIRC
@export var easing:EaseType = EaseType.EASE_IN_OUT
@export var animation_time:float = 0.3

@export_group('Collision')
@export_subgroup('Slices')
@export_flags_2d_physics var slice_collision_layer = 1 :
    set(v):
        if slices: slices.collision_layer = v
    get():
        if slices: return slices.collision_layer
        else: return 0
@export_flags_2d_physics var slice_collision_mask = 1 :
    set(v):
        if slices: slices.collision_mask = v
    get():
        if slices: return slices.collision_mask
        else: return 0
@export var slice_collision_priority:float = 1 :
    set(v):
        if slices: slices.collision_priority = v
    get():
        if slices: return slices.collision_priority
        else: return 0
@export_subgroup('Segments')
@export_flags_2d_physics var segment_collision_layer = 1 :
    set(v):
        if segments: segments.collision_layer = v
    get():
        if segments: return segments.collision_layer
        else: return 0
@export_flags_2d_physics var segment_collision_mask = 1 :
    set(v):
        if segments: segments.collision_mask = v
    get():
        if segments: return segments.collision_mask
        else: return 0
@export var segment_collision_priority:float = 1 :
    set(v):
        if segments: segments.collision_priority = v
    get():
        if segments: return segments.collision_priority
        else: return 0
@export_subgroup('Wheel Area Detector')
@export_flags_2d_physics var tad_collision_layer = 1 :
    set(v):
        if total_area_detector: total_area_detector.collision_layer = v
    get():
        if total_area_detector: return total_area_detector.collision_layer
        else: return 0
@export_flags_2d_physics var tad_collision_mask = 1 :
    set(v):
        if total_area_detector: total_area_detector.collision_mask = v
    get():
        if total_area_detector: return total_area_detector.collision_mask
        else: return 0
@export var tad_collision_priority:float = 1 :
    set(v):
        if total_area_detector: total_area_detector.collision_priority = v
    get():
        if total_area_detector: return total_area_detector.collision_priority
        else: return 0
    

@export_group('Slices and Segments')
@export var slice_gradient:GradientTexture1D :
    set(v):
        if v: v.width = int(radius)
        if slices: slices.slice_texture = v
    get():
        if slices and slices.slice_texture is GradientTexture1D: return slices.slice_texture
        else: return null
@export var segment_gradient:GradientTexture1D :
    set(v):
        if v: v.width = int(radius)
        if segments: segments.segment_texture = v
    get():
        if segments and segments.segment_texture is GradientTexture1D: return segments.segment_texture
        else: return null
## limits displayed slices/segments without removing slice/segment data
## useful for keeping a set of possible values and getting random subsets when you shuffle
## displays all segments if the value is < 0
@export var segment_limit:int = -1 :
    set(v):
        segment_limit = v
        _sync_num_segments()
## wheel slice size is based in relation to this value
@export var max_multiplier_value:int = 4 :
    set(v):
        if slices: slices.max_multiplier_value = v
    get():
        if slices: return slices.max_multiplier_value
        else: return 0
## Data objects defining the slices of the wheel (the orange parts that rotate and multiply the result)
## Must have the same number of elements as the value segments.
@export var multiplier_slice_data:Array[WheelSliceData] = [] :
    set(v):
        if slices: slices.slice_data = v
        _sync_num_segments()
    get():
        if slices: return slices.slice_data
        else: return []
## Data objects defining the segments of the wheel (the outlined parts that store the base values)
## Must have the same number of elements as the multiplier slices.
@export var value_segment_data:Array[WheelSegmentData] = [] :
    set(v):
        value_segment_data = v
        _sync_value_segment_data()
        _sync_num_segments()
#endregion


#region Onready Vars
# child scenes
# wheel components
@onready var slices:WheelSlices = %WheelSlices
@onready var segments:WheelSegments = %WheelSegments
@onready var wheel_overlay:WheelOverlay = %WheelOverlay
@onready var covers:WheelCovers = %WheelCovers
@onready var selector:WheelSelector = %WheelSelector
# detector components
@onready var total_area_detector:Area2D = %TotalAreaDetector # area2d covering the whole wheel
@onready var tad_collision_shape:CollisionShape2D = %TADCollision
#endregion


#region Local Vars
var tween:Tween # keeps track of wheel rotation, used to skip the animation on rapid input.
var connected_node_touching_segments:Array[int] = [] # used to detect if we're in multiple segments
#endregion

func _ready() -> void:
    if not InputMap.has_action(DROW_CLICK_ACTION):
        InputMap.add_action(DROW_CLICK_ACTION)
        var mouse_click_event = InputEventMouseButton.new()
        mouse_click_event.button_index = MOUSE_BUTTON_LEFT  
        InputMap.action_add_event(DROW_CLICK_ACTION, mouse_click_event)
    if not total_area_detector.mouse_exited.is_connected(_mouse_exited_wheel):
        total_area_detector.mouse_exited.connect(_mouse_exited_wheel)
    randomize()
    _bind_segment_area_detection()
    _sync_num_segments()
    _sync_radius()
    _sync_value_segment_data()

#region Value Sync
func _sync_radius():
    if slices: slices.maximum_radius = radius
    if segments: segments.radius = radius
    if wheel_overlay: wheel_overlay.radius = radius
    if covers: covers.radius = radius
    if selector: selector.radius = radius
    if cover_texture: cover_texture.width = int(radius)
    if slice_gradient: slice_gradient.width = int(radius)
    if segment_gradient: segment_gradient.width = int(radius)
    if tad_collision_shape: tad_collision_shape.shape.radius = radius + (outer_border_thickness / 2)
    set_custom_minimum_size(Vector2.ONE * ((2 * radius) + (outer_border_thickness)))

func _sync_value_segment_data():
    if segments: segments.segment_data = value_segment_data
    if covers: covers.segment_data = value_segment_data

func get_num_segments():
    var max_possible_segments = min(len(value_segment_data), len(multiplier_slice_data))    
    if segment_limit >= 0:
        return min(max_possible_segments, segment_limit)
    return max_possible_segments

## syncs all segments to the maximum possible number of segments with the data we have
func _sync_num_segments():
    var num_segments = get_num_segments()
    if slices:
        slices.slice_limit = num_segments
        snap_gimbal_to_valid_angle()
    if segments: segments.segment_limit = num_segments
    if wheel_overlay: wheel_overlay.num_borders = num_segments
    if covers: covers.cover_limit = num_segments
    if selector: selector.num_positions = num_segments
#endregion

#region Input Handling
## handles default select-by-mouse
func _mouse_entered_segment(slice_index:int):
    if not enable_mouse_input: return
    if disable_all_input: return

    selector_active = true
    selected_index = slice_index

## hides the selector if the mouse leaves the wheel.
## allows the user to show the selector without the mouse if something else grabs its attention
func _mouse_exited_wheel():
    if not enable_mouse_input: return
    if disable_all_input: return

    selector_active = false

## handle general direct wheel input
func _unhandled_input(_event: InputEvent) -> void:
    if disable_all_input: return
    
    if enable_mouse_input and selector_active and Input.is_action_just_pressed(DROW_CLICK_ACTION):
        var selection_valid = confirm_selection()
        if selection_valid and rotate_on_selection: rotate_right()

## used for when a body or area enters a segment
func _when_node_enters_segment(node:Node2D, segment_index:int):
    if node != node_as_selector: return
    if not segment_index in connected_node_touching_segments:
        connected_node_touching_segments.append(segment_index)
    if len(connected_node_touching_segments) == 1 and selected_index != connected_node_touching_segments[0]:
        selector_active = true
        selected_index = connected_node_touching_segments[0]
    else:
        selector_active = false
    print_debug(connected_node_touching_segments)

## used for when a body or area exits a segment
func _when_node_exits_segment(node:Node2D, segment_index:int):
    if node != node_as_selector: return
    print_debug("exiting segment...")
    var idx_to_remove:int = connected_node_touching_segments.find(segment_index)
    if idx_to_remove != -1:
        connected_node_touching_segments.remove_at(idx_to_remove)
    if len(connected_node_touching_segments) == 1 and selected_index != connected_node_touching_segments[0]:
        selector_active = true
        selected_index = connected_node_touching_segments[0]
    else:
        selector_active = false

func _bind_segment_area_detection():
    if not segments: return
    for i in segments.get_num_segments():
        var segment = segments.segments[i]
        if not segment.mouse_entered.is_connected(_mouse_entered_segment.bind(i)):
            segment.mouse_entered.connect(_mouse_entered_segment.bind(i))
        if not segment.body_entered.is_connected(_when_node_enters_segment.bind(i)):
            segment.body_entered.connect(_when_node_enters_segment.bind(i))
        if not segment.body_exited.is_connected(_when_node_exits_segment.bind(i)):
            segment.body_exited.connect(_when_node_exits_segment.bind(i))
        if not segment.area_entered.is_connected(_when_node_enters_segment.bind(i)):
            segment.area_entered.connect(_when_node_enters_segment.bind(i))
        if not segment.area_exited.is_connected(_when_node_exits_segment.bind(i)):
            segment.area_exited.connect(_when_node_exits_segment.bind(i))
#endregion


#region Wheely Info
## Returns detailed data for the currently selected slice of the wheel
func get_selection_data(even_if_unselectable:bool = false) -> WheelSelectionData:
    if not selector_active: return null
    if not value_segment_data[selected_index].selectable and not even_if_unselectable: return null

    var selection_data = WheelSelectionData.new()
    selection_data.selection_index = selected_index
    selection_data.slice_position = slice_position
    selection_data.base_value = value_segment_data[selected_index].value
    selection_data.multiplier = multiplier_slice_data[wrap_index(selected_index - slice_position, get_num_segments())].value
    selection_data.total_value = selection_data.base_value * selection_data.multiplier
    return selection_data


func num_remaining_selectable_segments() -> int :
    var count:int = 0
    for vsd:WheelSegmentData in value_segment_data:
        count += 1 if vsd.selectable else 0
    return count


func get_segments_with_matching_slices() -> Array[Array]:
    var return_array:Array[Array] = []
    for i in get_num_segments():
        var vsd = value_segment_data[i]
        var msd = multiplier_slice_data[wrap_index(i - slice_position, get_num_segments())]
        return_array.append([vsd, msd])
    return return_array


func get_selected_multiplier() -> WheelSliceData:
    return null if not selector_active else multiplier_slice_data[(selected_index - slice_position) % get_num_segments()]


func get_selected_segment() -> WheelSegmentData:
    return null if not selector_active else value_segment_data[selected_index]


## Returns true if there's no more valid selections, else returns false.
func puzzle_finished() -> bool:
    return num_remaining_selectable_segments() <= 0


func is_rotating():
    return tween and tween.is_running()
#endregion


#region Wheel Mutators
## returns true if the selection was valid, false otherwise
func confirm_selection():
    if disable_selection_during_animation and (tween and tween.is_running()): return false
    if not get_selected_segment() or not get_selected_segment().selectable: return false
    if disable_selected_segments: get_selected_segment().selectable = false
    if covers: covers.update_visibility(selected_index)
    new_segment_chosen.emit(get_selection_data(true))
    return true

## disables the selected segment without selecting it
func disable_selection():
    value_segment_data[selected_index].selectable = false

func reset(shuffle_values_:bool = true, shuffle_multipliers_:bool = true):
    if shuffle_values_: shuffle_values()
    if shuffle_multipliers_: shuffle_multipliers()
    make_all_selectable()

func shuffle_values():
    value_segment_data.shuffle()
    if segments: segments.for_all_segments(segments.update_segment_data)

func shuffle_multipliers():
    multiplier_slice_data.shuffle()
    if slices: slices.for_all_slices(slices.update_slice_data)

## Useful for when the multiplier value is being used for something else
func zero_all_multipliers():
    for msd in multiplier_slice_data: msd.value = 0
    if slices: slices.for_all_slices(slices.update_slice_data)

## Make all segments selectable again (hide all covers)
func make_all_selectable():
    for vsd in value_segment_data: vsd.selectable = true
    if segments: segments.for_all_segments(segments.update_segment_data)
    if covers: covers.for_all_segments(covers.update_visibility)

## Make all segments un-selectable (show all covers)
func disable_all():
    for vsd in value_segment_data: vsd.selectable = false
    if segments: segments.for_all_segments(segments.update_segment_data)
    if covers: covers.for_all_segments(covers.update_visibility)
#endregion


#region Animation
## Rotates the wheel one step counter-clockwise
func rotate_left():
    _rotate_one_step(false)

## Rotates the wheel one step clockwise
func rotate_right():
    _rotate_one_step(true)

func _rotate_one_step(clockwise:bool):
    # end any animations in progress
    if tween and tween.is_running():
        if disable_selection_during_animation: return # do not rotate during animation if disabled
        tween.custom_step(animation_time) # end the ongoing tween immediately


    # determine how we're moving
    var slice_angle_deg:float = 360.0 / get_num_segments()
    var from:float = slice_position * slice_angle_deg
    var to:float = from + (slice_angle_deg * (1 if clockwise else -1))

    # monitor our position
    slice_position += 1 if clockwise else -1

    # do the animation
    rotation_started.emit()
    tween = create_tween()
    slices.gimbal_rotation_deg = from
    tween.tween_property(slices, 'gimbal_rotation_deg', to, animation_time)\
         .set_trans(int(transition)) \
         .set_ease(int(easing))
    await tween.finished
    
    #announce we're done
    rotation_finished.emit()
    
## if we're not animating, snaps slice rotation to a valid wheel location
func snap_gimbal_to_valid_angle():
    if not (tween and tween.is_running()):
        if slices: slices.gimbal_rotation_deg = slice_position * (360 / max(1, get_num_segments()))
#endregion
