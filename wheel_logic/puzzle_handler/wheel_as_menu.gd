class_name WheelAsMenu
extends WheelPuzzle

const DRAIN_METADATA:StringName = 'draining'

@export var animation_time:float = 1.0

var tween

## override
func attach_wheel(wheel_:ComponentWheel):
    super(wheel_)
    if wheel.input_handler.has_signal('mouse_exited_wheel'):
        wheel.input_handler.mouse_exited_wheel.connect(func():
            _end_animation()
            wheel.zero_all_multipliers()
    )

func on_selection():
    _end_animation()
    wheel.zero_all_multipliers()
    tween = wheel.create_tween()
    tween.tween_method(
        func(v): wheel.slices.set_multiplier_at(wheel.get_selected_index(), v),
        wheel.get_selected_multiplier(),
        wheel.slices.max_value,
        animation_time,
    ).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func _end_animation():
    if tween and tween.is_running():
        tween.custom_step(animation_time)

func on_choice(_data:WheelSelectionData):
    pass ## relying on external scripts to handle choices

func reset():
    wheel.zero_all_multipliers()
