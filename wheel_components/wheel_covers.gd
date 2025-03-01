@tool
class_name WheelCovers
extends Control

######################
# region Export Vars
######################
@export_group('Properties')
## Number of covers to show.
@export var num_covers:int = 4 :
    set(v):
        num_covers = max(0, v)
        _match_desired_cover_number()
## Which covers are enabled. If empty, all covers are disabled.
## If it has fewer values than num_covers, disables the rest.
@export var show_cover:Array[bool] = []
## Color of each cover. Must have at least one value.
## If it has fewer values than num_covers, loops through the array.
## e.g.: If it only has one value, all covers will be that color.
@export var colors:Array[Color] = [Color.WHITE]
## Texture of each cover. If empty, no textures will be applied.
## If it has fewer values than num_covers, loops through the array.
## e.g.: If it only has one texture, all covers will have that texture.
@export var textures:Array[Texture2D] = []

@export_group('Size')
## Radius of the wheel
@export var radius:float = 100 :
    set(v): radius = max(0, v)
## How many points used to render the curved arc for each cover.
@export var fidelity:int = 20 :
    set(v): fidelity = max(2, v)

@export_group('Components')
@export var cover_scene:PackedScene
#endregion

########################
# region Core Function
########################
var _cover_children:Array = [] # keeps track of child order

func _ready() -> void:
    assert(cover_scene != null, 'covers must have a designated cover scene!')
    assert(len(colors) > 0, 'must have at least one valid color for covers!')
    update()

## Adjust number of cover children to match the desired number
## only adds or removes from the end of the list
func _match_desired_cover_number():
    var add_new_cover:Callable = func():
        var new_cover = cover_scene.instantiate()
        _cover_children.append(new_cover)
        add_child(new_cover)
    
    if len(_cover_children) != num_covers:
        WheelUtil.match_desired_value(_cover_children, num_covers, add_new_cover)
        for_all_covers(update_cover_data)

## Batch call a function with id func(index:int) for all covers
func for_all_covers(f_to_call:Callable):
    for i in num_covers:
        f_to_call.call(i)
        
func update_cover_data(index:int):
    index = WheelUtil.wrap_index(index, num_covers)
    var cover = _cover_children[index]
    if 'radius' in cover: cover.radius = radius
    if 'fidelity' in cover: cover.fidelity = fidelity
    if 'arc_angle_deg' in cover: cover.arc_angle_deg = WheelUtil.arc_angle_deg(num_covers)
    if 'color' in cover: cover.color = colors[WheelUtil.wrap_index(index, len(colors))]
    if 'texture' in cover: cover.texture = null if len(textures) == 0 else textures[WheelUtil.wrap_index(index, len(textures))]
    if 'rotation_degrees' in cover: cover.rotation_degrees = index * WheelUtil.arc_angle_deg(num_covers)
    if 'update' in cover and cover.update is Callable: cover.update()
    if len(show_cover) <= index or not show_cover[index]: cover.hide()

## alias for for_all_covers(update_cover_data)
func update():
    _match_desired_cover_number()
    for_all_covers(update_cover_data)
#endregion