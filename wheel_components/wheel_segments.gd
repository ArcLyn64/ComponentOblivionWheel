@tool
class_name WheelSegments
extends Control

######################
# region Export Vars 
######################
@export_group('Properties')
## Number of segments to show
@export var num_segments:int = 4 :
    set(v): num_segments = max(0, v)
## Color of each segment. Must have at least one value.
## If it has fewer values than num_segments, loops through the array.
## e.g.: If it only has one value, all segments will be that color.
@export var colors:Array[Color] = [Color.WHITE]
## Texture of each segment. If empty, no textures will be applied.
## If it has fewer values than num_segments, loops through the array.
## e.g.: If it only has one texture, all segments will have that texture.
@export var textures:Array[Texture2D] = []
## Value of each segment. Must have at least one value.
## If it has fewer values than num_segments, loops through the array.
## e.g.: If it only has one value, all segments will have that value.
## e.g.: If it has more values than num_segments, it will take the first num_segments values,
## which is equivalent to taking a random sample.
@export var values:Array[int] = [-2, -1, 1, 2]

@export_group('Size')
## Radius of the wheel
@export var radius:int = 100 :
    set(v): radius = max(0, v)
## How many points used to render the curved arc for each segment.
@export var polygon_fidelity:int = 20 :
    set(v): polygon_fidelity = max(2, v)
## How many points used to render the curved arc for each hitbox
@export var hitbox_fidelity:int = 5 :
    set(v): hitbox_fidelity = max(2, v)
    
@export_group('Collision')
@export_flags_2d_physics var collision_layer = 1
@export_flags_2d_physics var collision_mask = 1
@export var collision_priority:float = 1

@export_group('Components')
@export var segment_scene:PackedScene

#endregion

########################
# region Core Function
########################
var _segment_children:Array = [] # keeps track of child order

func _ready() -> void:
    assert(segment_scene != null, 'segments must have a designated segment scene!')
    assert(len(colors) > 0, 'must have at least one valid color for segments!')
    assert(len(values) > 0, 'must have at least one valid value for segments!')

## Adjust number of segment children to match the desired number
## only adds or removes from the end of the list
func _match_desired_segment_number():
    var add_new_segment:Callable = func():
        var new_segment = segment_scene.instantiate()
        _segment_children.append(new_segment)
        add_child(new_segment)
    
    if len(_segment_children) != num_segments:
        WheelUtil.match_desired_value(_segment_children, num_segments, add_new_segment)
        for_all_segments(update_segment_data)

## Batch call a function with id func(index:int) for all segments
func for_all_segments(f_to_call:Callable):
    for i in num_segments:
        f_to_call.call(i)
        
func update_segment_data(index:int):
    index = WheelUtil.wrap_index(index, num_segments)
    var segment = _segment_children[index]
    if 'radius' in segment: segment.radius = radius
    if 'polygon_fidelity' in segment: segment.polygon_fidelity = polygon_fidelity
    if 'hitbox_fidelity' in segment: segment.hitbox_fidelity = polygon_fidelity
    if 'value' in segment: segment.value = values[WheelUtil.wrap_index(index, len(values))]
    if 'color' in segment: segment.color = colors[WheelUtil.wrap_index(index, len(colors))]
    if 'texture' in segment: segment.texture = null if len(textures) == 0 else textures[WheelUtil.wrap_index(index, len(textures))]
    if 'rotation_degrees' in segment: segment.rotation_degrees = index * WheelUtil.arc_angle_deg(num_segments)
    if 'update' in segment and segment.update is Callable: segment.update()
#endregion
 