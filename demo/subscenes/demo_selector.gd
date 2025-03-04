extends CenterContainer

@onready var wheel:ComponentWheel = %ComponentWheel
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
    wheel.reset()
    wheel.input_handler.mouse_exited_wheel.connect(func():
        demo_name_label.text = ''
    )

## on select
func _update_displayed_demo():
    demo_name_label.text = demos[wheel.get_selected_index() % len(demos)]

## on choose
func _go_to_selected_demo(selected_data:WheelSelectionData):
    wheel.disable_all_segments()
    var demo_control = get_node('/root/DemoRoot')
    if demo_control and demo_control is DemoControl:
        demo_control.change_scenes(demos[selected_data.selection_index])
#endregion
