@tool
class_name WheelSlices
extends Control

###############################
# region Enums, Alias & Const
###############################
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
#endregion

##################
# region Signals
##################
signal rotation_started()
signal rotation_finished()
#endregion

######################
# region Export Vars
######################
@export_group('Properties')
## Number of slices to show
@export var num_slices:int = 4 :
    set(v):
        num_slices = max(0, v)
        _match_desired_slice_number()
## rotation position
@export var position_index:int = 0 :
    set(v): position_index = WheelUtil.wrap_index(0, num_slices)
## Color of each slice. Must have at least one value.
## If it has fewer values than num_slices, loops through the array.
## e.g.: If it only has one value, all slices will be that color.
@export var colors:Array[Color] = [Color.ORANGE]
## Texture of each slice. If empty, no textures will be applied.
## If it has fewer values than num_slices, loops through the array.
## e.g.: If it only has one texture, all slices will have that texture.
@export var textures:Array[Texture2D] = []
## Value of each slice. Must have at least one value.
## If it has fewer values than num_slices, loops through the array.
## e.g.: If it only has one value, all slices will have that value.
## e.g.: If it has more values than num_slices, it will take the first num_slices values,
## which is equivalent to taking a random sample.
@export var values:Array[int] = [1, 2, 3, 4]
## Maximum value for a slice. Used to determine how full each slice should look.
@export var max_value:int = 4

@export_group('Animation')
@export var transition:TweenType = TweenType.TRANS_CIRC
@export var easing:EaseType = EaseType.EASE_IN_OUT
@export var animation_time:float = 0.3

@export_group('Size')
## Radius of the wheel, and the maximum radius a slice can be.
@export var maximum_radius:float = 100 :
    set(v): maximum_radius = max(0, v)
## How many points used to render the curved arc for each slice.
@export var fidelity:int = 20 :
    set(v): fidelity = max(2, v)

@export_group('Components')
@export var slice_scene:PackedScene
#endregion

########################
# region Core Function
########################
@onready var slice_gimbal:Control = %SliceGimbal

var tween:Tween # keeps track of wheel rotations, used to skip the animation on rapid input.
var _slice_children:Array = [] # keeps track of child order

func _ready() -> void:
    assert(slice_scene != null, 'slices must have a designated slice scene!')
    assert(len(colors) > 0, 'must have at least one valid color for slices!')
    assert(len(values) > 0, 'must have at least one valid value for slices!')
    update()

## Adjust number of slice children to match the desired number
## only adds or removes from the end of the list
func _match_desired_slice_number():
    var add_new_slice:Callable = func():
        var new_slice = slice_scene.instantiate()
        _slice_children.append(new_slice)
        slice_gimbal.add_child(new_slice)
    
    if len(_slice_children) != num_slices:
        WheelUtil.match_desired_value(_slice_children, num_slices, add_new_slice)
        for_all_slices(update_slice_data)

## Batch call a function with id func(index:int) for all slices
func for_all_slices(f_to_call:Callable):
    for i in num_slices:
        f_to_call.call(i)
        
## updates data for the selected slice and call its update function, if it has one.
func update_slice_data(index:int):
    index = WheelUtil.wrap_index(index, num_slices)
    var slice = _slice_children[index]
    if 'maximum_radius' in slice: slice.maximum_radius = maximum_radius
    if 'fidelity' in slice: slice.fidelity = fidelity
    if 'arc_angle_deg' in slice: slice.arc_angle_deg = WheelUtil.arc_angle_deg(num_slices)
    if 'value' in slice: slice.value = values[WheelUtil.wrap_index(index, len(values))]
    if 'max_value' in slice: slice.max_value = max_value
    if 'color' in slice: slice.color = colors[WheelUtil.wrap_index(index, len(colors))]
    if 'texture' in slice: slice.texture = null if len(textures) == 0 else textures[WheelUtil.wrap_index(index, len(textures))]
    if 'rotation_degrees' in slice: slice.rotation_degrees = index * WheelUtil.arc_angle_deg(num_slices)
    if 'update' in slice and slice.update is Callable: slice.update()

# figures out which slice matches with the selected index, then update that slice.
func update_selected_slice(selected_index = 0):
    update_slice_data(WheelUtil.wrap_index(selected_index - position_index, num_slices))

func update():
    _match_desired_slice_number()
    for_all_slices(update_slice_data)
#endregion
        
####################
# region Animation
####################
## Rotates the wheel one step counter-clockwise
func rotate_left():
    _rotate_one_step(false)

## Rotates the wheel one step clockwise
func rotate_right():
    _rotate_one_step(true)

func _rotate_one_step(clockwise:bool):
    if not slice_gimbal: return
    # end any animations in progress
    if tween and tween.is_running():
        tween.custom_step(animation_time) # end the ongoing tween immediately

    # determine how we're moving
    var slice_angle_deg:float = WheelUtil.arc_angle_deg(num_slices)
    var from:float = position_index * slice_angle_deg
    var to:float = from + (slice_angle_deg * (1 if clockwise else -1))

    # monitor our position
    position_index += 1 if clockwise else -1

    # do the animation
    rotation_started.emit()
    tween = create_tween()
    slice_gimbal.rotation_degrees = from
    tween.tween_property(slice_gimbal, 'rotation_degrees', to, animation_time)\
         .set_trans(int(transition)) \
         .set_ease(int(easing))
    await tween.finished
    
    #announce we're done
    rotation_finished.emit()
    
## if we're not animating, snaps slice rotation to a valid wheel location
func snap_gimbal_to_valid_angle():
    if not (tween and tween.is_running()):
        if slice_gimbal: slice_gimbal.rotation_degrees = position_index * WheelUtil.arc_angle_deg(num_slices)
#endregion
