@tool
class_name RenderedWheelSelector
extends Control

######################
# region Export Vars
######################
@export_group('Properties')
## Number of positions the selector can be in.
@export var num_positions:int = 4 :
    set(v):
        num_positions = max(1, v)
        update()
## Selected position.
@export var selected_index:int = 0 :
    set(v):
        selected_index = WheelUtil.wrap_index(v, num_positions)
        update_selector_position()
## Selector color.
@export var color:Color = Color.DEEP_SKY_BLUE

@export_group('Size')
## Radius of the wheel.
## Consider making this smaller than the main wheel radius relative to the outer border thickness.
@export var radius:float = 100 :
    set(v): radius = max(0, v)
## How many points used to render the curved arc for each cover.
@export var fidelity:int = 20 :
    set(v): fidelity = max(2, v)
## Thickness of the selector.
@export var thickness:float = 5.0
## Offset to shrink the arc to fit within the inner borders.
## Likely should match how thick the inner borders are.
@export var edge_offset:float = 5.0
#endregion

########################
# region Core Function
########################
@onready var selector_line:Line2D = %RenderedSelector

func _ready() -> void:
    assert(selector_line != null, 'selector must have a display line!')
    update()

func update():
    selector_line.default_color = color
    # calculate how much arc length to remove to fit the selector inside the borders
    var selector_radius:float = radius - (thickness / 2)
    var arc_length = edge_offset + thickness
    var arc_angle_offset = 360 * arc_length / (2 * PI * selector_radius)
    var display_angle = WheelUtil.arc_angle_deg(num_positions) - arc_angle_offset
    # offset for the init point to fit the selector inside the borders
    # I hate math so much
    var selector_offset = Vector2.RIGHT * (thickness + edge_offset) / sin(deg_to_rad(WheelUtil.arc_angle_deg(num_positions) / 2)) / 2

    if num_positions == 1:
        selector_line.points = WheelUtil.create_arc_points(selector_radius, fidelity)
    else:
        selector_line.points = [selector_offset] + WheelUtil.create_arc_points(selector_radius, fidelity, display_angle)
    
    update_selector_position()

func update_selector_position():
    selector_line.rotation_degrees = (selected_index * WheelUtil.arc_angle_deg(num_positions))

#endregion