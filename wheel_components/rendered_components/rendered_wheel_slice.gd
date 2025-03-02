@tool
class_name WheelSlice
extends Area2D

const CENTER_POINT:Array[Vector2] = [Vector2.ZERO]

######################
# region Export Vars
######################
## Radius of the wheel, and the maximum radius a slice can be.
@export var maximum_radius:float = 100 :
    set(v): maximum_radius = max(0, v)
## The angle of this slice's arc.
@export var arc_angle_deg:float = 90 :
    set(v): arc_angle_deg = clampf(v, 0.0, 360.0)
## How many points used to render the curved arc for this slice.
@export var fidelity:int = 20 :
    set(v): fidelity = max(2, v)
## Slice multiplier value, also determines fullness.
@export var value:int = 4
## Maximum value for a slice. Used to determine how full the slice should look.
@export var max_value:int = 4
## Color of this slice's polygon.
@export var color:Color = Color.ORANGE :
    set(v):
        color = v
        if polygon: polygon.color = color
## Texture of this slice's polygon.
## I wouldn't recommend using anything but GradientTexture1D without some modifications.
@export var texture:Texture2D :
    set(v):
        texture = v
        if polygon: polygon.texture = texture
# endregion

@onready var polygon:Polygon2D = %WheelPolygon

func _ready() -> void:
    update()

func update():
    color = color # triggers setter to update polygon
    texture = texture # triggers setter to update polygon
    var radius = maximum_radius * clampf(float(max(value, 0)) / float(max(1, max_value)), 0, 1)
    polygon.set_polygon(
        CENTER_POINT + WheelUtil.create_arc_points(radius, fidelity, arc_angle_deg)        
    )