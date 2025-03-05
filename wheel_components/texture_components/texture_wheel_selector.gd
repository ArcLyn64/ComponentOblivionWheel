@tool
class_name TextureWheelSelector
extends Control

######################
# region Export Vars
######################
# Size of the wheel.
@export var radius:float = 100 :
    set(v): radius = max(0, v)
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
## Selector texture
@export var texture:Texture2D :
    set(v):
        texture = v
        if texture_rect: texture_rect.texture = texture
## Selector rotation offset (to make sure this points in the right direction depending on the original texture.)
## Set so position 0 is pointing straight to the right.
@export var texture_angle_offset_deg:float = 90 :
    set(v):
        texture_angle_offset_deg = v
        update_selector_position()
## Number of segments to show.
# endregion

@onready var texture_rect:TextureRect = %TextureRect

func _ready() -> void:
    update()

func update_selector_position():
    texture_rect.rotation_degrees = (selected_index * WheelUtil.arc_angle_deg(num_positions)) + texture_angle_offset_deg

func update():
    texture_rect.size = Vector2.ONE * radius * 2
    texture_rect.position = Vector2.ONE * -radius
    texture_rect.pivot_offset = Vector2.ONE * radius
    texture_rect.texture = texture
    update_selector_position()
