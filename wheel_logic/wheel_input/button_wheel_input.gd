class_name ButtonWheelInput
extends WheelInput

signal wheel_deselected()

@export var disable_selection_during_animation:bool = false
@export var select_index_actions:Array[StringName] = [
    'ui_right',
    'ui_down',
    'ui_left',
    'ui_up',
]
@export var choose_action:StringName = 'ui_accept'
@export var deselect_action:StringName = 'ui_text_completion_replace'

func attach_wheel(wheel_:ComponentWheel):
    super(wheel_)

func handle_input(_event: InputEvent):
    if not input_enabled: return
    
    for i in len(select_index_actions):
        if Input.is_action_just_pressed(select_index_actions[i]):
            wheel.select_index(i)
            break
     
    if wheel.is_selector_active():
        if Input.is_action_just_pressed(deselect_action):
            deselect_wheel()
        elif Input.is_action_just_pressed(choose_action):
            wheel.confirm_selection()

func select_segment(index:int):
    if not input_enabled: return
    if disable_selection_during_animation and wheel.is_rotating(): return 
    wheel.select_index(index)

func deselect_wheel():
    if not input_enabled: return
    wheel.disable_selector()
    wheel_deselected.emit()