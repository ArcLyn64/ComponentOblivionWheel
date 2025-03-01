class_name WheelUtil
extends Resource

static func create_arc_points(radius:float, fidelity:int, arc_angle_deg_:float = 360) -> Array[Vector2]:
    arc_angle_deg_ = clampf(abs(arc_angle_deg_), 0, 360) # clamp this to the circle
    fidelity = max(2, fidelity)
    var points:Array[Vector2] = []
    var pos: Vector2 = (Vector2.RIGHT * radius).rotated(deg_to_rad(-arc_angle_deg_/2))
    var rotation_increment:float = deg_to_rad(arc_angle_deg_ / (fidelity - 1))
    for i in fidelity:
        points += [pos]
        pos = pos.rotated(rotation_increment)
    return points

static func wrap_index(index, length) -> int:
    if length <= 0:
        return index
    if index < 0:
        return wrap_index(index + length, length)
    else:
        return index % length

static func arc_angle_deg(slices:int) -> float:
    slices = max(1, slices)
    return 360.0 / max(1, slices)

## used to match the correct number of children
## this was repeated a lot for generating wheel elements
## so I moved it into a util
## list: the list of elements to match the size
## size: the desired size to match
## add_func: a function matching the id func() that handles adding children to list.
static func match_desired_value(list:Array, size:int, add_func:Callable):
    ## make sure we have the right number of slices
    if len(list) > size:
        # remove extra slices from the end
        var needed_removed = len(list) - size
        for _i in needed_removed:
            var removed = list.pop_back()
            if removed: removed.queue_free() # would love to do this in one line but have to null check
    elif len(list) < size:
        # create new slices using the add_func
        var needed_new = size - len(list)
        for _i in needed_new:
            add_func.call()

