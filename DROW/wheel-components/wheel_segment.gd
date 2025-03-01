@tool
class_name WheelSegment
extends Area2D

@onready var hitbox:CollisionPolygon2D = %CollisionShape
@onready var polygon:Polygon2D = %WheelPolygon

var segment_data:WheelSegmentData = null :
    set(v):
        segment_data = v
        update_color()

func update_color():
    if segment_data:
        # invert so that it acts as a color filter, with the subtract blending on the polygon
        polygon.color = segment_data.color.inverted()

func set_collision_properties(
    collision_layer_:int,
    collision_mask_:int,
    collision_priority_:float,
) :
    self.collision_layer = collision_layer_
    self.collision_mask = collision_mask_
    self.collision_priority = collision_priority_