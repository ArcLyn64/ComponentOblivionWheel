class_name FollowNodeWheelInput
extends WheelInput

signal node_exited_wheel()

@export var choose_action:StringName = ''

## this should be either a body or area
## unfortunately resources cannot have node export vars
## so just be sure to attach follow node sometime
var follow_node:Node2D = null

## using this dict as a set with dummy value true
var _follow_node_touching_segments_set:Dictionary = {}

func attach_wheel(wheel_:ComponentWheel):
    super(wheel_)
    _connect_wheel_signals()

func attach_follow_node(fn:Node2D):
    follow_node = fn
    _follow_node_touching_segments_set = {}
    for index in _detect_colliding_areas():
        _follow_node_touching_segments_set[index] = true

func handle_input(_event: InputEvent):
    if not input_enabled: return
    
    if wheel.is_selector_active() and Input.is_action_just_pressed(choose_action):
        wheel.confirm_selection()

func _node_entered_segment(node:Node2D, index:int):
    if node != follow_node: return
    if not input_enabled or wheel.is_rotating(): return
    _follow_node_touching_segments_set[index] = true
    if len(_follow_node_touching_segments_set.keys()) == 1:
        wheel.select_index(_follow_node_touching_segments_set.keys()[0])

func _node_exited_segment(node:Node2D, index:int):
    if node != follow_node: return
    if not input_enabled or wheel.is_rotating(): return
    _follow_node_touching_segments_set.erase(index)
    if len(_follow_node_touching_segments_set.keys()) == 1:
        wheel.select_index(_follow_node_touching_segments_set.keys()[0])

func _node_exited_wheel(node:Node2D):
    if node != follow_node: return
    if not input_enabled: return
    _follow_node_touching_segments_set = {}
    wheel.disable_selector()
    node_exited_wheel.emit()

func _detect_colliding_areas() -> Array[int]:
    if not follow_node: return []
    var overlapping_segments:Array[int] = []
    wheel.segments.for_all_segments(func(index):
        if wheel.segments.is_node_in_segment(follow_node, index):
            follow_node.append(index)
    )
    return overlapping_segments

func _connect_wheel_signals():
    if not wheel: return

    wheel.segments.segment_area.body_exited.connect(_node_exited_wheel)
    wheel.segments.segment_area.area_exited.connect(_node_exited_wheel)

    wheel.segments.for_all_segments(func(index):
        wheel.segments.bind_signal('body_entered', index, _node_entered_segment.bind(index))
        wheel.segments.bind_signal('area_entered', index, _node_entered_segment.bind(index))

        wheel.segments.bind_signal('body_exited', index, _node_exited_segment.bind(index))
        wheel.segments.bind_signal('area_exited', index, _node_exited_segment.bind(index))
    )
        
