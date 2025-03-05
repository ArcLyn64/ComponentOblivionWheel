class_name MouseWheelInput
extends WheelInput

signal mouse_exited_wheel()

const COW_CLICK_ACTION = 'COW_wheel_click'

## if click_action remains empty, this resource will autocreate an action instead.
@export var click_action:String = ''
@export var disable_selection_during_animation:bool = false

func attach_wheel(wheel_:ComponentWheel):
    super(wheel_)
    if click_action.is_empty(): 
        click_action = COW_CLICK_ACTION
        if not InputMap.has_action(COW_CLICK_ACTION):
            _add_default_click_action()
    _connect_wheel_signals()

func handle_input(_event: InputEvent):
    if not input_enabled: return
    
    if wheel.is_selector_active() and Input.is_action_just_pressed(click_action):
        wheel.confirm_selection()

func _add_default_click_action():
    InputMap.add_action(COW_CLICK_ACTION)
    var mouse_click_event = InputEventMouseButton.new()
    mouse_click_event.button_index = MOUSE_BUTTON_LEFT  
    InputMap.action_add_event(COW_CLICK_ACTION, mouse_click_event)   

func _mouse_entered_segment(index:int):
    if not input_enabled: return
    if disable_selection_during_animation and wheel.is_rotating(): return 
    wheel.select_index(index)

func _mouse_exited_wheel():
    if not input_enabled: return
    wheel.disable_selector()
    mouse_exited_wheel.emit()

func _connect_wheel_signals():
    if not wheel: return
    wheel.segments.segment_area.mouse_exited.connect(_mouse_exited_wheel)
    wheel.segments.for_all_segments(func(index):
        wheel.segments.bind_signal('mouse_entered', index, _mouse_entered_segment.bind(index))
    )
        