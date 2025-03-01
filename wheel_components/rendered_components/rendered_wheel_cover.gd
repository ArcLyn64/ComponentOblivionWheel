@tool
class_name WheelCover
extends Polygon2D

const CENTER_POINT:Array[Vector2] = [Vector2.ZERO]

######################
# region Export Vars
######################
## Radius of the wheel
@export var radius:float = 100 :
    set(v): radius = max(0, v)
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
# endregion

func _ready() -> void:
    update()

func update():
    set_polygon(
        CENTER_POINT + WheelUtil.create_arc_points(radius, fidelity, arc_angle_deg)        
    )