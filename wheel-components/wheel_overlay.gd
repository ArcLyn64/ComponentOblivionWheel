@tool
class_name WheelOverlay
extends Control

#region Export Vars
@export_group('Borders')
@export var num_borders:int :
    set(v):
        num_borders = max(0, v)
        if num_borders == 1: # don't show only one border
            num_borders = 0
        _match_desired_border_number()
@export var radius:float = 30.0 :
    set(v):
        if v != radius:
            radius = v
            update_inner_border_points()
            update_outer_border_points()
@export var outer_border_fidelity:int = 60 :
    set(v):
        v = max(10, v)
        if outer_border_fidelity != v:
            outer_border_fidelity = v
            update_outer_border_points()
@export var overlay_color:Color = Color.WHITE :
    set(v):
        if overlay_color != v:
            overlay_color = v
            update_color()
@export var outer_border_thickness:float = 5 :
    set(v):
        outer_border_thickness = v
        if outer_border: outer_border.width = v
    get():
        if outer_border:
            outer_border.width = outer_border_thickness
            return outer_border.width
        else: return outer_border_thickness
@export var inner_border_thickness:float = 2 :
    set(v):
        if inner_border_thickness != v:
            inner_border_thickness = v
            update_inner_border_thickness()
@export var outer_border_texture:Texture2D :
    set(v):
        if outer_border: outer_border.texture = v
    get():
        if outer_border: return outer_border.texture 
        else: return null
@export_group('Covers')
@export_group('Selector')
#endregion

@onready var border_parent:Control = %BorderParent
@onready var cover_parent:Control = %CoverParent
@onready var selector_parent:Control = %SelectorParent
@onready var outer_border:Line2D = %OuterBorder

var inner_borders:Array[Line2D] = []

func _ready() -> void:
    _match_desired_border_number()
    update_inner_border_thickness()
    update_inner_border_points()
    update_outer_border_points()
    update_color()

#region Borders
func _match_desired_border_number():
    if not border_parent: return
    var add_new_border:Callable = func():
        var new_border = Line2D.new()
        inner_borders.append(new_border)
        border_parent.add_child(new_border)
    
    if len(inner_borders) != num_borders:
        WheelUtil.match_desired_value(inner_borders, num_borders, add_new_border)
        update_inner_border_points()
        update_inner_border_thickness()
        update_color()
 
func update_inner_border_points():
    for i in num_borders:
        if i >= len(inner_borders): return
        var border:Line2D = inner_borders[i]
        border.points = [
            Vector2.ZERO,
            Vector2.RIGHT * radius
        ]
        border.rotation_degrees = (i * _get_arc_angle_deg()) - (-_get_arc_angle_deg()/2)

func update_outer_border_points():
    if outer_border: outer_border.points = WheelUtil.create_arc_points(radius, outer_border_fidelity)

func update_inner_border_thickness():
    for border in inner_borders:
        border.width = inner_border_thickness

func update_color():
    if outer_border: outer_border.default_color = overlay_color
    for border in inner_borders:
        border.default_color = overlay_color
#endregion

func _get_arc_angle_deg() -> float:
    return 360.0 / max(1, num_borders)
