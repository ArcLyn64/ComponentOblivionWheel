@tool
class_name RenderedWheelOverlay
extends Control

######################
# region Export Vars
######################
## Number of segments to show.
@export_group('Properties')
@export var num_borders:int = 4 :
    set(v):
        num_borders = max(0, v)
        _match_desired_border_number()

@export_group('Size')
## Size of the wheel.
@export var radius:float = 100 :
    set(v): radius = max(0, v)
## How many points to use to render the outer wheel
@export var fidelity:int = 20 :
    set(v): fidelity = max(2, v)

@export_group('Inner Border')
## Color of each inner border. Must have at least one value.
## If it has fewer values than num_borders, loops through the array.
## e.g.: If it only has one value, all borders will be that color.
@export var inner_border_colors:Array[Color] = [Color.WHITE]
## Texture of each inner border. If empty, no texture will be applied.
## If it has fewer values than num_borders, loops through the array.
## e.g.: If it only has one texture, all borders will have that texture.
@export var inner_border_textures:Array[Texture2D] = []
## thickness of inner borders
@export var inner_border_thickness:float = 5.0

@export_group('Outer Border')
## Color of the outer border
@export var outer_border_color:Color = Color.WHITE
## Texture of the outer border
@export var outer_border_texture:Texture2D
## thickness of outer borders
@export var outer_border_thickness:float = 10.0
#endregion

########################
# region Core Function
########################
@onready var outer_border:Line2D = %OuterBorder
var _inner_borders:Array[Line2D] = []

func _ready() -> void:
    assert(len(inner_border_colors) > 0, 'must have at least one valid color for inner borders!')
    assert(outer_border != null, "can't find outer border!")
    update()

## Batch call a function with id func(index:int) for all segments
func for_all_inner_borders(f_to_call:Callable):
    for i in num_borders:
        f_to_call.call(i)

func _match_desired_border_number():
    var add_new_border:Callable = func():
        var new_border = Line2D.new()
        _inner_borders.append(new_border)
        add_child(new_border)
    
    if len(_inner_borders) != num_borders:
        WheelUtil.match_desired_value(_inner_borders, num_borders, add_new_border)
        for_all_inner_borders(update_inner_border)

func update_inner_border(index:int):
    index = WheelUtil.wrap_index(index, num_borders) 
    var border:Line2D = _inner_borders[index]
    border.default_color = inner_border_colors[WheelUtil.wrap_index(index, len(inner_border_colors))]
    border.texture = null if len(inner_border_textures) == 0 else inner_border_textures[WheelUtil.wrap_index(index, len(inner_border_textures))]
    border.texture_mode = Line2D.LINE_TEXTURE_TILE
    border.width = inner_border_thickness
    border.points = [
        Vector2.ZERO,
        Vector2.RIGHT * radius
    ]
    border.rotation_degrees = (index * WheelUtil.arc_angle_deg(num_borders)) - (-WheelUtil.arc_angle_deg(num_borders)/2)
    
func update_outer_border():
    outer_border.points = WheelUtil.create_arc_points(radius, fidelity)
    outer_border.default_color = outer_border_color
    outer_border.texture = outer_border_texture
    outer_border.width = outer_border_thickness

func update():
    _match_desired_border_number()
    for_all_inner_borders(update_inner_border)
    update_outer_border()

# endregion