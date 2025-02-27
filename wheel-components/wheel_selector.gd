@tool
class_name WheelSelector
extends Control

#region Export Vars
@export_group('Data')
@export var selector_index = 0 :
    set(v):
        selector_index = WheelUtil.wrap_index(v, num_positions)
        update_selector_angle()
@export var num_positions:int :
    set(v):
        v = max(0, v)
        if v != num_positions:
            num_positions = v
            selector_index = selector_index
            update_points()
## data from overlay
@export var inner_border_thickness:float = 2 :
    set(v):
        if inner_border_thickness != v:
            inner_border_thickness = v
            update_points()
## data from overlay
@export var outer_border_thickness:float = 2 :
    set(v):
        if outer_border_thickness != v:
            outer_border_thickness = v
            update_points()

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
@export var selector_thickness:float = 5 :
    set(v):
        selector_thickness = v
        if rendered_selector: rendered_selector.width = v
        update_points()
    get():
        if rendered_selector: # shenanigans to overcome initialization order
            rendered_selector.width = selector_thickness
            return rendered_selector.width
        else: return selector_thickness
@export var color:Color = Color.DEEP_SKY_BLUE :
    set(v):
        if rendered_selector: rendered_selector.default_color = v
    get():
        if rendered_selector: return rendered_selector.default_color
        else: return Color.DEEP_SKY_BLUE
#endregion

@onready var rendered_selector:Line2D = %RenderedSelector

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    update_points()
    update_selector_angle()

func update_points():
    if not rendered_selector: return
    # calculate how much arc length to remove to fit the selector inside the borders
    var selector_radius:float = radius - (outer_border_thickness / 2) - (selector_thickness / 2)
    var arc_length = inner_border_thickness + selector_thickness
    var arc_angle_offset = 360 * arc_length / (2 * PI * selector_radius)
    var display_angle = _get_arc_angle_deg() - arc_angle_offset
    # offset for the init point to fit the selector inside the borders
    # I hate math so much
    var selector_offset = Vector2.RIGHT * (selector_thickness + inner_border_thickness) / sin(deg_to_rad(_get_arc_angle_deg() / 2)) / 2

    if num_positions == 1:
        rendered_selector.points = WheelUtil.create_arc_points(selector_radius, fidelity)
    else:
        rendered_selector.points = [selector_offset] + WheelUtil.create_arc_points(selector_radius, fidelity, display_angle)


func update_selector_angle():
    if rendered_selector: rendered_selector.rotation_degrees = (selector_index * _get_arc_angle_deg())

func _get_arc_angle_deg() -> float:
    return 360.0 / max(1, num_positions)

