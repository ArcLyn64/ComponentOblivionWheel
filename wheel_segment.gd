@tool
class_name WheelSegment
extends Area2D

@onready var hitbox_shape:CollisionPolygon2D = %CollisionShape
@onready var wheel_polygon:Polygon2D = %WheelPolygon

var segment_data:WheelSegmentData = null

func render(
    segment_data_:WheelSegmentData,
    polygon_texture:Texture2D,
    polygon_points:Array[Vector2],
    hitbox_points:Array[Vector2],
    collision_layer_:int,
    collision_mask_:int,
    collision_priority_:int,
):
    # update our data
    self.segment_data = segment_data_

    # render the polygon
    wheel_polygon.set_polygon(polygon_points)
    wheel_polygon.color = segment_data.color.inverted() # so that it acts as a color filter, with the subtract blending on the polygon
    wheel_polygon.texture = polygon_texture
    
    # set up the hitbox
    hitbox_shape.polygon = hitbox_points
    self.collision_layer = collision_layer_
    self.collision_mask = collision_mask_
    self.collision_priority = collision_priority_
