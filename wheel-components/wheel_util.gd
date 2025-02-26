class_name WheelUtil
extends Resource

static func create_arc_points(radius:float, fidelity:int, arc_angle_deg:float = 360) -> Array[Vector2]:
    arc_angle_deg = clampf(abs(arc_angle_deg), 0, 360) # clamp this to the circle
    fidelity = max(2, fidelity)
    var points:Array[Vector2] = []
    var pos: Vector2 = (Vector2.RIGHT * radius).rotated(deg_to_rad(-arc_angle_deg/2))
    var rotation_increment:float = deg_to_rad(arc_angle_deg / (fidelity - 1))
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