@tool
class_name TextureWheelOverlay
extends Control

######################
# region Export Vars
######################
# Size of the wheel.
@export var radius:float = 100 :
    set(v): radius = max(0, v)
## Texture for the overlay
@export var texture:Texture2D :
    set(v):
        texture = v
        if texture_rect: texture_rect.texture = texture
# endregion

@onready var texture_rect:TextureRect = %TextureRect

func _ready() -> void:
    update()

func update():
    texture_rect.size = Vector2.ONE * radius * 2
    texture_rect.position = Vector2.ONE * -radius
    texture_rect.pivot_offset = Vector2.ONE * radius
    texture_rect.texture = texture