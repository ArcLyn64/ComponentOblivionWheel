@tool
class_name WheelSegments
extends Control

const CENTER_POINT:Array[Vector2] = [Vector2.ZERO]

signal num_segments_changed()

#region Export Vars
@export_group('Data')
@export var maximum_segments:int = 4 :
    set(v):
        maximum_segments = max(0, v)
        _match_desired_segment_number()
@export var segment_data:Array[WheelSegmentData] = [] :
    set(v):
        segment_data = v
        _match_desired_segment_number()
        for_all_segments(update_segment_data)

@export_group('Appearance')
@export var radius:float = 30.0 :
    set(v):
        if v != radius:
            radius = v
            for_all_segments(update_all_segment_points)
@export var segment_fidelity:int = 20 :
    set(v):
        v = max(2, v)
        if v != segment_fidelity:
            segment_fidelity = v
            for_all_segments(update_polygon_points)
@export var hitbox_fidelity:int = 5 :
    set(v):
        v = max(2, v)
        if v != hitbox_fidelity:
            hitbox_fidelity = v
            for_all_segments(update_hitbox_points)
@export var segment_texture:Texture2D = null:
    set(v):
        segment_texture = v
        for_all_segments(update_segment_texture)

@export_group('Collision')
@export_flags_2d_physics var collision_layer = 1 :
    set(v):
        collision_layer = v
        for_all_segments(update_hitbox_collision)
@export_flags_2d_physics var collision_mask = 1 :
    set(v):
        collision_mask = v
        for_all_segments(update_hitbox_collision)
@export var collision_priority:float = 1 :
    set(v):
        collision_priority = v
        for_all_segments(update_hitbox_collision)
#endregion

#region Onready Vars
@onready var wheel_segment_scene:PackedScene = preload("uid://cdrvckmfxk4r")
#endregion

#region Local Vars
var segments:Array[WheelSegment] = []
#endregion

func _ready() -> void:
    _match_desired_segment_number()
    for_all_segments(update_segment_data)
    for_all_segments(update_segment_texture)
    for_all_segments(update_all_segment_points)
    for_all_segments(update_hitbox_collision)

## Adjust number of segment children to match the desired number
## only adds or removes from the end of the list
func _match_desired_segment_number():
    var add_new_segment:Callable = func():
        if not wheel_segment_scene: return
        var new_segment = wheel_segment_scene.instantiate()
        segments.append(new_segment)
        add_child(new_segment)
    
    if len(segments) != get_num_segments():
        WheelUtil.match_desired_value(segments as Array[Node], get_num_segments(), add_new_segment)
        for_all_segments(update_segment_data)
        for_all_segments(update_all_segment_points)
        num_segments_changed.emit()
        
## Batch call a function with id func(index:int) for all segments
func for_all_segments(f_to_call:Callable):
    for i in get_num_segments():
        f_to_call.call(i)

func update_segment_texture(segment_index:int):
    if not segment_index < len(segments): return
    segments[segment_index].polygon.texture = segment_texture

func update_segment_data(segment_index:int):
    if not segment_index < len(segments): return
    segments[segment_index].segment_data = segment_data[segment_index]

func update_all_segment_points(segment_index:int):
    update_polygon_points(segment_index)
    update_hitbox_points(segment_index)

func update_polygon_points(segment_index:int):
    if not segment_index < len(segments): return
    segments[segment_index].polygon.set_polygon(
        CENTER_POINT + WheelUtil.create_arc_points(radius, segment_fidelity, _get_segment_arc_angle_deg())
    )
    segments[segment_index].rotation_degrees = segment_index * _get_segment_arc_angle_deg()

func update_hitbox_points(segment_index:int):
    if not segment_index < len(segments): return
    segments[segment_index].hitbox.polygon = CENTER_POINT + WheelUtil.create_arc_points(radius, hitbox_fidelity, _get_segment_arc_angle_deg())

func update_hitbox_collision(segment_index:int):
    if not segment_index < len(segments): return
    segments[segment_index].set_collision_properties(collision_layer, collision_mask, collision_priority)

func get_num_segments():
    return min(maximum_segments, len(segment_data))

func _get_segment_arc_angle_deg() -> float:
    return 360.0 / max(1, get_num_segments())
