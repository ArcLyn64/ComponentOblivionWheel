@tool
class_name WheelSlice
extends Area2D

@onready var hitbox:CollisionPolygon2D = %CollisionShape
@onready var polygon:Polygon2D = %WheelPolygon

var slice_data:WheelSliceData = null :
    set(v):
        slice_data = v
        update_color()

func update_color():
    if slice_data:
        polygon.color = slice_data.color

func set_collision_properties(
    collision_layer_:int,
    collision_mask_:int,
    collision_priority_:float,
) :
    self.collision_layer = collision_layer_
    self.collision_mask = collision_mask_
    self.collision_priority = collision_priority_