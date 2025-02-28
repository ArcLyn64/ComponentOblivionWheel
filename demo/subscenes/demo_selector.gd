extends CenterContainer

@onready var wheel:DROW = %DROW
@onready var demo_name_label:Label = %DemoName

var demos:Array[StringName] = [
    'Classic Wheel',
    'Mash to Fill',
    'Mash to Fill (Drain)',
    'Chase the Wedge',
    'Wheel as Play Area',
]

var tween:Tween = null

func _ready() -> void:
    wheel.segment_limit = len(demos)
    wheel.total_area_detector.mouse_exited.connect(func():
        demo_name_label.text = ''
        _end_current_animation()
    )
    wheel.reset()
    wheel.zero_all_multipliers()

#region Signal Receivers
func _update_displayed_demo():
    demo_name_label.text = demos[wheel.selected_index % len(demos)]
    _end_current_animation()
    tween = create_tween()
    tween.tween_method(_update_wheel_selected_slice, 0, wheel.max_multiplier_value, 1.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func _go_to_selected_demo(selected_data:WheelSelectionData):
    _end_current_animation()
    wheel.disable_all()
    var demo_control = get_node('/root/DemoRoot')
    if demo_control and demo_control is DemoControl:
        demo_control.change_scenes(demos[selected_data.selection_index])
#endregion

#region Util
func _end_current_animation():
    if tween and tween.is_running():
        tween.kill()
    wheel.zero_all_multipliers()

func _update_wheel_selected_slice(value:int):
    wheel.update_selected_slice_data(value)

#endregion
