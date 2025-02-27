@tool
class_name WheelCovers
extends Control

const CENTER_POINT:Array[Vector2] = [Vector2.ZERO]

#region Export Vars
@export_group('Data')
@export var cover_limit:int = 4 :
    set(v):
        cover_limit = max(0, v)
        _match_desired_cover_number()
@export var segment_data:Array[WheelSegmentData] = [] :
    set(v):
        segment_data = v
        _match_desired_cover_number()

@export_group('Appearance')
@export var radius:float = 30.0 :
    set(v):
        if v != radius:
            radius = v
            update_points()
@export var fidelity:int = 20 :
    set(v):
        v = max(2, v)
        if v != fidelity:
            fidelity = v
            update_points()
@export var color:Color = Color.WHITE :
    set(v):
        if color != v:
            color = v
            update_color()
@export var texture:Texture2D = null:
    set(v):
        texture = v
        update_texture()

var covers:Array[Polygon2D] = []

func _ready() -> void:
    _match_desired_cover_number()
    update_points()
    update_color()
    update_texture()
    for_all_segments(update_visibility)

func _match_desired_cover_number():
    var add_new_cover:Callable = func():
        var new_cover = Polygon2D.new()
        covers.append(new_cover)
        add_child(new_cover)
            
    if len(covers) != get_num_covers():
        WheelUtil.match_desired_value(covers, get_num_covers(), add_new_cover)
        update_points()
        for_all_segments(update_visibility)

## f_to_call is of id func(index)
func for_all_segments(f_to_call:Callable):
    for i in get_num_covers():
        f_to_call.call(i)

func update_points():
    var cover_points:Array[Vector2] = \
        CENTER_POINT + WheelUtil.create_arc_points(radius, fidelity, _get_cover_arc_angle_deg())
    for_all_segments(func(i):
        covers[i].set_polygon(cover_points)
        covers[i].rotation_degrees = i * _get_cover_arc_angle_deg()
    )

func update_color():
    for cover in covers: cover.color = color

func update_texture():
    for cover in covers: cover.texture = texture

func update_visibility(index:int):
    var selectable = segment_data[index].selectable
    covers[index].visible = not selectable

func get_num_covers():
    return min(cover_limit, len(segment_data))

func _get_cover_arc_angle_deg() -> float:
    return 360.0 / max(1, get_num_covers())
