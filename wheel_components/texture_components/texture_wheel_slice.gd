@tool
class_name TextureWheelSlice
extends Control

######################
# region Export Vars
######################
## Radius of the wheel, and the maximum radius a slice can be.
@export var radius:float = 100 :
    set(v): radius = max(0, v)
## Slice multiplier value, also determines fullness.
@export var value:int = 4
## The values that can be assigned.
## These map onto the textures at the same index
## These are sorted for consistency (since values gets shuffled in wheel_slices)
## sigh... i wish we had static typed dict exports...
@export var possible_values:Array[int] = [] :
    set(v):
        possible_values = v.duplicate() # sort() is in place, but we don't wanna manipulate the original array.
        possible_values.sort()
## The textures that can be assigned.
## These map onto the values at the same index
## remember possible_values is sorted, so these should be in order from small to large.
## sigh... i wish we had static typed dict exports...
@export var possible_textures:Array[Texture2D] = []
## Modulate for the texture rect
@export var color:Color = Color.WHITE :
    set(v):
        color = v
        if texture_rect: texture_rect.modulate = color
# endregion

@onready var texture_rect:TextureRect = %TextureRect

func _ready() -> void:
    update()

func update():
    if not texture_rect: await ready
    texture_rect.size = Vector2.ONE * radius * 2
    texture_rect.position = Vector2.ONE * -radius
    texture_rect.pivot_offset = Vector2.ONE * radius
    texture_rect.modulate = color
    if value in possible_values:
        var i = possible_values.find(value)
        if i < len(possible_textures):
            texture_rect.texture = possible_textures[i]
        else:
            texture_rect.texture = null
    else:
        texture_rect.texture = null
