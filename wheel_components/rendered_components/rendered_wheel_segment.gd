@tool
class_name WheelSegment
extends Area2D

const CENTER_POINT:Array[Vector2] = [Vector2.ZERO]

######################
# region Export Vars
######################
## Radius of the wheel
@export var radius:float = 100 :
    set(v): radius = max(0, v)
## The angle of this segment's arc.
@export var arc_angle_deg:float = 90 :
    set(v): arc_angle_deg = clampf(v, 0.0, 360.0)
## How many points used to render the curved arc for this segment.
@export var polygon_fidelity:int = 20 :
    set(v): polygon_fidelity = max(2, v)
## How many points used to render the curved arc for this segment's hitbox.
@export var hitbox_fidelity:int = 20 :
    set(v): hitbox_fidelity = max(2, v)
## Segment base value.
@export var value:int = 4
## Color of this segment's polygon.
@export var color:Color = Color.ORANGE :
    set(v):
        color = v
        if polygon: polygon.color = color
## Texture of this segment's polygon.
## I wouldn't recommend using anything but GradientTexture1D without some modifications.
@export var texture:Texture2D :
    set(v):
        texture = v
        if polygon: polygon.texture = texture
# endregion

@onready var hitbox:CollisionPolygon2D = %CollisionShape
@onready var polygon:Polygon2D = %WheelPolygon

func _ready() -> void:
    update()

func update():
    color = color # triggers setter to update polygon
    texture = texture # triggers setter to update polygon
    polygon.set_polygon(
        CENTER_POINT + WheelUtil.create_arc_points(radius, polygon_fidelity, arc_angle_deg)        
    )
    hitbox.polygon = CENTER_POINT + WheelUtil.create_arc_points(radius, hitbox_fidelity, arc_angle_deg)        