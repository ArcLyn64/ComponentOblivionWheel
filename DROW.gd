@tool
class_name DROW
extends Control

#region Enums & Const
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
#endregion


#region Signals
signal new_segment_selected()
signal new_segment_chosen(selection_data:WheelSelectionData)
signal rotation_started()
signal rotation_finished()
# you have to call puzzle_finished() to check intentionally with this wheel...
signal render_finished() # useful for debug
signal node_on_border() # used for connected node area detection
#endregion


#region Exports
@export_group('State')
@export var selected_index:int = 0 :
    set(v):
        selected_index = _wrap_index(v, get_num_slices())
        if selector_active:
            new_segment_selected.emit()
        render()
@export var slice_position:int = 0 :
    set(v):
        slice_position = _wrap_index(v, get_num_slices())
        render()
@export var selector_active:bool = true:
    set(v):
        selector_active = v
        render()

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
        overlay_color = v
        render()
@export var outer_border_thickness:float = 5.0 :
    set(v):
        outer_border_thickness = v
        render()
@export var outer_border_texture:GradientTexture2D :
    set(v):
        outer_border_texture = v
        render()
@export var inner_border_thickness:float = 10.0 :
    set(v):
        inner_border_thickness = v
        render()
@export var selector_color:Color = Color.BLUE :
    set(v):
        selector_color = v
        render()
@export var selector_thickness:float = 5.0:
    set(v):
        selector_thickness = v
        render()
@export var cover_color:Color = Color('#3b3b3bc0') :
    set(v):
        cover_color = v
        render()
@export var cover_texture:GradientTexture1D :
    set(v):
        cover_texture = v
        if cover_texture: cover_texture.width = int(radius)
        render()

@export_group('Size and Rendering Settings')
@export var radius:float = 100.0 :
    set(v):
        radius = v
        if cover_texture: cover_texture.width = int(radius)
        if slice_gradient: slice_gradient.width = int(radius)
        if segment_gradient: segment_gradient.width = int(radius)
        render()
@export var slice_fidelity:int = 20 :
    set(v):
        slice_fidelity = v
        render()
@export var segment_fidelity:int = 20 :
    set(v):
        segment_fidelity = v
        render()
@export var outer_border_fidelity:int = 60 :
    set(v):
        outer_border_fidelity = v
        render()
@export var selector_fidelity:int = 20 :
    set(v):
        selector_fidelity = v
        render()
@export var hitbox_fidelity:int = 5 :
    set(v):
        hitbox_fidelity = v
        render()
@export var cover_fidelity:int = 20 :
    set(v):
        cover_fidelity = v
        render()

@export_group('Animation')
@export var transition:TweenType = TweenType.TRANS_CIRC
@export var easing:EaseType = EaseType.EASE_IN_OUT
@export var animation_time:float = 0.3

@export_group('Collision')
@export_subgroup('Slices')
@export_flags_2d_physics var slice_collision_layer = 1 :
    set(v):
        slice_collision_layer = v
        render()
@export_flags_2d_physics var slice_collision_mask = 1 :
    set(v):
        slice_collision_mask = v
        render()
@export var slice_collision_priority:int = 1 :
    set(v):
        slice_collision_priority = v
        render()
@export_subgroup('Segments')
@export_flags_2d_physics var segment_collision_layer = 1 :
    set(v):
        segment_collision_layer = v
        render()
@export_flags_2d_physics var segment_collision_mask = 1 :
    set(v):
        segment_collision_mask = v
        render()
@export var segment_collision_priority:int = 1 :
    set(v):
        segment_collision_priority = v
        render()
@export_subgroup('Wheel Area Detector')
@export_flags_2d_physics var tad_collision_layer = 1 :
    set(v):
        tad_collision_layer = v
        render()
@export_flags_2d_physics var tad_collision_mask = 1 :
    set(v):
        tad_collision_mask = v
        render()
@export var tad_collision_priority:int = 1 :
    set(v):
        tad_collision_priority = v
        render()
    

@export_group('Slices and Segments')
@export var slice_gradient:GradientTexture1D :
    set(v):
        slice_gradient = v
        if slice_gradient: slice_gradient.width = int(radius)
        render()
@export var segment_gradient:GradientTexture1D :
    set(v):
        segment_gradient = v
        if segment_gradient: segment_gradient.width = int(radius)
        render()
## limits displayed slices/segments without removing slice/segment data
## useful for keeping a set of possible values and getting random subsets when you shuffle
## displays all segments if the value is <= 0
@export var maximum_segments:int = -1 :
    set(v):
        maximum_segments = v
        render()
## wheel slice size is based in relation to this value
@export var max_multiplier_value:int = 4 :
    set(v):
        max_multiplier_value = v
        render()
## Data objects defining the slices of the wheel (the orange parts that rotate and multiply the result)
## Must have the same number of elements as the value segments.
@export var multiplier_slice_data:Array[WheelSliceData] = [] :
    set(v):
        multiplier_slice_data = v
        render()
## Data objects defining the segments of the wheel (the outlined parts that store the base values)
## Must have the same number of elements as the multiplier slices.
@export var value_segment_data:Array[WheelSegmentData] = [] :
    set(v):
        value_segment_data = v
        render()
#endregion


#region Onready Vars
# child scenes
@onready var wheel_slice_scene:PackedScene = preload("uid://c4xtb2itc034m")
@onready var wheel_segment_scene:PackedScene = preload("uid://cdrvckmfxk4r")
# wheel components
@onready var slice_parent:Control = %SliceParent
@onready var segment_parent:Control = %SegmentParent
@onready var wheel_overlay_parent:Control = %WheelOverlayParent
@onready var cover_parent:Control = %CoverParent
@onready var outer_border:Line2D = %OuterBorder
@onready var selector:Line2D = %Selector
# detector components
@onready var total_area_detector:Area2D = %TotalAreaDetector # area2d covering the whole wheel
@onready var tad_collision_shape:CollisionShape2D = %TADCollision
#endregion


#region Local Vars
var slices:Array[WheelSlice] = []
var segments:Array[WheelSegment] = []
var inner_borders:Array[Line2D] = []
var covers:Array[Polygon2D] = []
var tween:Tween # keeps track of wheel rotation, used to skip the animation on rapid input.
var connected_node_touching_segments:Array[int] = [] # used to detect if we're in multiple segments
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
    selection_data.multiplier = multiplier_slice_data[_wrap_index(selected_index - slice_position, get_num_slices())].value
    selection_data.total_value = selection_data.base_value * selection_data.multiplier
    return selection_data


func get_num_slices() -> int:
    var _segment_data:Array[WheelSegmentData] = value_segment_data.filter(func(e): return e != null)
    var _slice_data:Array[WheelSliceData] = multiplier_slice_data.filter(func(e): return e != null)
    var n = min(len(_segment_data), len(_slice_data))
    if maximum_segments >= 0:
        return min(n, maximum_segments)
    else:
        return n


func num_remaining_selectable_segments() -> int :
    var count:int = 0
    for vsd:WheelSegmentData in value_segment_data:
        count += 1 if vsd.selectable else 0
    return count


func get_segments_with_matching_slices() -> Array[Array]:
    var return_array:Array[Array] = []
    for i in get_num_slices():
        var vsd = value_segment_data[i]
        var msd = multiplier_slice_data[_wrap_index(i - slice_position, get_num_slices())]
        return_array.append([vsd, msd])
    return return_array


func get_selected_multiplier() -> WheelSliceData:
    return null if not selector_active else multiplier_slice_data[(selected_index - slice_position) % get_num_slices()]


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
    new_segment_chosen.emit(get_selection_data(true))
    return true

## disables the selected segment without selecting it
func disable_selection():
    value_segment_data[selected_index].selectable = false

func reset(shuffle_values_:bool = true, shuffle_multipliers_:bool = true):
    if shuffle_values_: shuffle_values()
    if shuffle_multipliers_: shuffle_multipliers()
    make_all_selectable()
    render()

func shuffle_values():
    value_segment_data.shuffle()
    render()

func shuffle_multipliers():
    multiplier_slice_data.shuffle()
    render()

## Useful for when the multiplier value is being used for something else
func zero_all_multipliers():
    for msd in multiplier_slice_data: msd.value = 0
    render()

## Make all segments selectable again (hide all covers)
func make_all_selectable():
    for vsd in value_segment_data: vsd.selectable = true
    render()

## Make all segments un-selectable (show all covers)
func disable_all():
    for vsd in value_segment_data: vsd.selectable = false
    render()
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
    var slice_angle_deg:float = 360.0 / get_num_slices()
    var from:float = slice_position * slice_angle_deg
    var to:float = from + (slice_angle_deg * (1 if clockwise else -1))

    # monitor our position
    slice_position += 1 if clockwise else -1

    # do the animation
    rotation_started.emit()
    tween = create_tween()
    slice_parent.rotation_degrees = from
    tween.tween_property(slice_parent, 'rotation_degrees', to, animation_time)\
         .set_trans(int(transition)) \
         .set_ease(int(easing))
    await tween.finished
    
    #announce we're done
    rotation_finished.emit()
#endregion


#region Rendering the Wheel
## Called when one of our properties is modified
func render():
    if not wheel_slice_scene: return # we need this scene to work

    ## data cleaning
    # filter out null values
    var _segment_data:Array[WheelSegmentData] = value_segment_data.filter(func(e): return e != null)
    var _slice_data:Array[WheelSliceData] = multiplier_slice_data.filter(func(e): return e != null)
    # set up useful reference values
    var num_slices = min(len(_segment_data), len(_slice_data))
    if maximum_segments > 0: num_slices = min(num_slices, maximum_segments)
    var slice_arc_angle_deg:float = 360.0 / max(1, num_slices)
    
    ## if we're not animating, snap slice_parent rotation to a valid wheel location
    if not (tween and tween.is_running()):
        slice_parent.rotation_degrees = slice_position * slice_arc_angle_deg

    ## extra operations based on data outlier cases
    if num_slices <= 0: return # no wheel data, don't render
    if not len(_segment_data) == len(_slice_data):
        print("Mismatch between num segments (%d) and num slices (%d), rendering with the lower value." % [len(_segment_data), len(_slice_data)]) 

    ## force data sets to be the same size
    _segment_data = _segment_data.slice(0, num_slices)
    _slice_data = _slice_data.slice(0, num_slices)
    
    ## handle container sizing
    set_custom_minimum_size(Vector2.ONE * ((2 * radius) + (outer_border_thickness)))
    
    ## handle total area detector
    total_area_detector.collision_layer = tad_collision_layer
    total_area_detector.collision_mask = tad_collision_mask
    total_area_detector.collision_priority = tad_collision_priority
    tad_collision_shape.shape.radius = radius + (outer_border_thickness / 2)
    if not total_area_detector.mouse_exited.is_connected(_mouse_exited_wheel):
        total_area_detector.mouse_exited.connect(_mouse_exited_wheel)

    
    ## render the parts of wheel
    _render_slices(num_slices, _slice_data, slice_arc_angle_deg)
    _render_segments(num_slices, _segment_data, slice_arc_angle_deg)
    _render_inner_border(num_slices, slice_arc_angle_deg)
    _render_outer_border()
    _render_selector(slice_arc_angle_deg)
    _render_covers(num_slices, slice_arc_angle_deg)
    
    render_finished.emit()
    
    
func _render_slices(num_slices:int, _slice_data:Array[WheelSliceData], slice_arc_angle_deg:float): 
    ## make sure we have the right number of slices
    if len(slices) > num_slices:
        # remove extra slices from the end
        for slice in slices.slice(num_slices): # ha, slices.slice()
            slice.queue_free()
        slices = slices.slice(0, num_slices) # we wanna resize the slice array to remove the things we queued to free
    elif len(slices) < num_slices:
        # create new slices
        var needed_new_slices = num_slices - len(slices)
        for _i in needed_new_slices:
            var new_slice = wheel_slice_scene.instantiate()
            slices.append(new_slice)
            slice_parent.add_child(new_slice)

    ## update the existing slice data
    for i in len(slices):
        var slice = slices[i]
        var data = _slice_data[i]
        var display_radius = radius * min(1, (float(max(data.value, 0)) / max_multiplier_value))
        var hitbox_radius = radius
        var offset:Array[Vector2] = [Vector2.ZERO]
        var polygon_points:Array[Vector2] = offset + _create_arc_points(display_radius, slice_fidelity, slice_arc_angle_deg)
        var hitbox_points:Array[Vector2] = offset + _create_arc_points(hitbox_radius, hitbox_fidelity, slice_arc_angle_deg)
        slice.render(data, slice_gradient, polygon_points, hitbox_points, slice_collision_layer, slice_collision_mask, slice_collision_priority)
        slice.rotation_degrees = i * slice_arc_angle_deg

func _render_segments(num_segments:int, _segment_data:Array[WheelSegmentData], segment_arc_angle_deg:float):
    ## make sure we have the right number of segmentss
    if len(segments) > num_segments:
        # remove extra segments from the end
        for segment in segments.slice(num_segments):
            segment.queue_free()
        segments = segments.slice(0, num_segments) # we wanna resize the segments array to remove the things we queued to free
    elif len(segments) < num_segments:
        # create new segments
        var needed_new_segments = num_segments - len(segments)
        for _i in needed_new_segments:
            var new_segment = wheel_segment_scene.instantiate()
            segments.append(new_segment)
            segment_parent.add_child(new_segment)

    ## update the existing segment data
    for i in len(segments):
        var segment = segments[i]
        var data = _segment_data[i]
        var display_radius = radius
        var hitbox_radius = radius
        var offset:Array[Vector2] = [Vector2.ZERO]
        var polygon_points:Array[Vector2] = offset + _create_arc_points(display_radius, segment_fidelity, segment_arc_angle_deg)
        var hitbox_points:Array[Vector2] = offset + _create_arc_points(hitbox_radius, hitbox_fidelity, segment_arc_angle_deg)
        segment.render(data, segment_gradient, polygon_points, hitbox_points, segment_collision_layer, segment_collision_mask, segment_collision_priority)
        segment.rotation_degrees = i * segment_arc_angle_deg
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


func _render_inner_border(num_borders:int, slice_arc_angle_deg:float):
    ## make sure we have the right number of inner_borders
    if len(inner_borders) > num_borders:
        # remove extra inner_borders from the end
        for border in inner_borders.slice(num_borders):
            border.queue_free()
        inner_borders = inner_borders.slice(0, num_borders)
    elif len(inner_borders) < num_borders:
        # create new inner_borders
        var needed_new_borders = num_borders - len(inner_borders)
        for _i in needed_new_borders:
            var new_border = Line2D.new()
            inner_borders.append(new_border)
            wheel_overlay_parent.add_child(new_border)
    
    # don't show the single line if there's only one wheel segment
    if num_borders == 1:
        inner_borders[0].hide()
    else:
        inner_borders[0].show()
    
    ## update existing border lines
    for i in num_borders:
        var border:Line2D = inner_borders[i]
        border.points = [
            Vector2.ZERO,
            Vector2.RIGHT * radius
        ]
        border.width = inner_border_thickness
        border.default_color = overlay_color
        border.rotation_degrees = (i * slice_arc_angle_deg) - (-slice_arc_angle_deg/2)


func _render_outer_border():
    outer_border.points = _create_arc_points(radius, outer_border_fidelity)
    outer_border.width = outer_border_thickness
    outer_border.default_color = overlay_color
    outer_border.texture = outer_border_texture


func _render_selector(slice_arc_angle_deg:float):
    if not selector_active:
        selector.hide()
        return

    # calculate how much arc length to remove to fit the selector inside the borders
    var selector_radius:float = radius - (outer_border_thickness / 2) - (selector_thickness / 2)
    var arc_length = inner_border_thickness + (selector_thickness)
    var arc_angle_offset = 360 * arc_length / (2 * PI * selector_radius)
    # offset for the init point to fit the selector inside the borders
    # I hate math so much
    var selector_offset = Vector2.RIGHT * (selector_thickness + inner_border_thickness) / sin(deg_to_rad(slice_arc_angle_deg / 2)) / 2

    selector.show()
    selector.width = selector_thickness
    selector.default_color = selector_color
    selector.rotation_degrees = (selected_index * slice_arc_angle_deg)
    if get_num_slices() == 1:
        pass
        selector.points = _create_arc_points(selector_radius, selector_fidelity)
    else:
        selector.points = [selector_offset] + _create_arc_points(selector_radius, selector_fidelity, slice_arc_angle_deg - arc_angle_offset)


func _render_covers(num_covers:int, slice_arc_angle_deg:float):
    ## make sure we have the right number of covers
    if len(covers) > num_covers:
        # remove extra covers from the end
        for cover in covers.slice(num_covers):
            cover.queue_free()
        covers = covers.slice(0, num_covers)
    elif len(covers) < num_covers:
        # create new covers
        var needed_new_covers = num_covers - len(covers)
        for _i in needed_new_covers:
            var new_cover = Polygon2D.new()
            covers.append(new_cover)
            cover_parent.add_child(new_cover)
    
    ## update existing covers
    var cover_points = [Vector2.ZERO] + _create_arc_points(radius, cover_fidelity, slice_arc_angle_deg)
    for i in num_covers:
        var cover:Polygon2D = covers[i]
        cover.set_polygon(cover_points)
        cover.color = cover_color
        cover.texture = cover_texture
        cover.rotation_degrees = i * slice_arc_angle_deg
        cover.visible = not value_segment_data[i].selectable
#endregion


#region Util
func _wrap_index(index, length) -> int:
    if length <= 0:
        return index
    if index < 0:
        return _wrap_index(index + length, length)
    else:
        return index % length


# I'd rather this be in some util class but it's here to make sure this code is portable
func _create_arc_points(_radius:float, fidelity:int, arc_angle_deg:float = 360) -> Array[Vector2]:
    fidelity = max(2, fidelity)
    var points:Array[Vector2] = []
    var pos: Vector2 = (Vector2.RIGHT * _radius).rotated(deg_to_rad(-arc_angle_deg/2))
    var rotation_increment:float = deg_to_rad(arc_angle_deg / (fidelity - 1))
    for i in fidelity:
        points += [pos]
        pos = pos.rotated(rotation_increment)
    return points
#endregion


func _ready() -> void:
    if not InputMap.has_action(DROW_CLICK_ACTION):
        InputMap.add_action(DROW_CLICK_ACTION)
        var mouse_click_event = InputEventMouseButton.new()
        mouse_click_event.button_index = MOUSE_BUTTON_LEFT  
        InputMap.action_add_event(DROW_CLICK_ACTION, mouse_click_event)
    randomize()
    render()
