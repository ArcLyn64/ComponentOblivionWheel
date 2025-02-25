@tool
class_name WheelSlice
extends Area2D

@onready var hitbox_shape:CollisionPolygon2D = %CollisionShape
@onready var wheel_polygon:Polygon2D = %WheelPolygon

var slice_data:WheelSliceData = null

func render(
    slice_data_:WheelSliceData,
    polygon_texture:Texture2D,
    polygon_points:Array[Vector2],
    hitbox_points:Array[Vector2],
    collision_layer_:int,
    collision_mask_:int,
    collision_priority_:int,
):
    # update our data
    self.slice_data = slice_data_

    # render the polygon
    wheel_polygon.set_polygon(polygon_points)
    wheel_polygon.color = slice_data.color
    wheel_polygon.texture = polygon_texture
    
    # set up the hitbox
    hitbox_shape.polygon = hitbox_points
    self.collision_layer = collision_layer_
    self.collision_mask = collision_mask_
    self.collision_priority = collision_priority_
