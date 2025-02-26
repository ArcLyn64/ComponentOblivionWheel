@tool
class_name WheelSlices
extends Control

const CENTER_POINT:Array[Vector2] = [Vector2.ZERO]

#region Export Vars
@export_group('Data')
@export var maximum_slices:int = 4 :
    set(v):
        maximum_slices = max(0, v)
        _match_desired_slice_number()
@export var slice_data:Array[WheelSliceData] = [] :
    set(v):
        slice_data = v
        _match_desired_slice_number()
        for_all_slices(update_slice_data)
@export var max_multiplier_value:int = 4:
    set(v):
        if v != max_multiplier_value:
            max_multiplier_value = v
            for_all_slices(update_all_slice_points)

@export_group('Appearance')
@export var gimbal_rotation_deg:float = 0.0 :
    set(v):
        if slice_parent: slice_parent.rotation_degrees = v
    get():
        if slice_parent: return slice_parent.rotation_degrees
        else: return 0
@export var maximum_radius:float = 30.0 :
    set(v):
        if v != maximum_radius:
            maximum_radius = v
            for_all_slices(update_all_slice_points)
@export var slice_fidelity:int = 20 :
    set(v):
        v = max(2, v)
        if v != slice_fidelity:
            slice_fidelity = v
            for_all_slices(update_polygon_points)
@export var hitbox_fidelity:int = 5 :
    set(v):
        v = max(2, v)
        if v != hitbox_fidelity:
            hitbox_fidelity = v
            for_all_slices(update_hitbox_points)
@export var slice_texture:Texture2D = null:
    set(v):
        slice_texture = v
        for_all_slices(update_slice_texture)

@export_group('Collision')
@export_flags_2d_physics var collision_layer = 1 :
    set(v):
        collision_layer = v
        for_all_slices(update_hitbox_collision)
@export_flags_2d_physics var collision_mask = 1 :
    set(v):
        collision_mask = v
        for_all_slices(update_hitbox_collision)
@export var collision_priority:float = 1 :
    set(v):
        collision_priority = v
        for_all_slices(update_hitbox_collision)
#endregion

#region Onready Vars
@onready var wheel_slice_scene:PackedScene = preload("uid://c4xtb2itc034m")
@onready var slice_parent:Control = %SliceGimbal
#endregion

#region Local Vars
var slices:Array[WheelSlice] = []
#endregion

func _ready() -> void:
    _match_desired_slice_number()
    for_all_slices(update_slice_data)
    for_all_slices(update_slice_texture)
    for_all_slices(update_all_slice_points)
    for_all_slices(update_hitbox_collision)

## Adjust number of slice children to match the desired number
## only adds or removes from the end of the list
func _match_desired_slice_number():
    var add_new_slice:Callable = func():
        if not wheel_slice_scene: return
        var new_slice = wheel_slice_scene.instantiate()
        slices.append(new_slice)
        slice_parent.add_child(new_slice)
    
    if len(slices) != get_num_slices():
        WheelUtil.match_desired_value(slices as Array[Node], get_num_slices(), add_new_slice)
        for_all_slices(update_slice_data)
        for_all_slices(update_all_slice_points)
        
## Batch call a function with id func(index:int) for all slices
func for_all_slices(f_to_call:Callable):
    for i in get_num_slices():
        f_to_call.call(i)

func update_slice_texture(slice_index:int):
    if not slice_index < len(slices): return
    slices[slice_index].polygon.texture = slice_texture

func update_slice_data(slice_index:int):
    if not slice_index < len(slices): return
    slices[slice_index].slice_data = slice_data[slice_index]

func update_all_slice_points(slice_index:int):
    update_polygon_points(slice_index)
    update_hitbox_points(slice_index)

func update_polygon_points(slice_index:int):
    if not slice_index < len(slices): return
    var slice = slices[slice_index]
    var value = slice.slice_data.value
    var display_radius = maximum_radius * min(1, (float(max(value, 0)) / max_multiplier_value))
    slice.polygon.set_polygon(
        CENTER_POINT + WheelUtil.create_arc_points(display_radius, slice_fidelity, _get_slice_arc_angle_deg())
    )
    slice.rotation_degrees = slice_index * _get_slice_arc_angle_deg()

func update_hitbox_points(slice_index:int):
    if not slice_index < len(slices): return
    slices[slice_index].hitbox.polygon = CENTER_POINT + WheelUtil.create_arc_points(maximum_radius, hitbox_fidelity, _get_slice_arc_angle_deg())

func update_hitbox_collision(slice_index:int):
    if not slice_index < len(slices): return
    slices[slice_index].set_collision_properties(collision_layer, collision_mask, collision_priority)

func get_num_slices():
    return min(maximum_slices, len(slice_data))

func _get_slice_arc_angle_deg() -> float:
    return 360.0 / max(1, get_num_slices())
