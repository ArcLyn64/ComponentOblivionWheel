extends CenterContainer

const BAR_SIZE_TOTAL:float = 500
const TIME:float = 10.0
const TAP_VALUE:int = 20
const TICK_RATE:float = 0.0167 * 5
const SUCCESS_THRESHOLD:float = 0.75

@onready var wheel:DROW = %DROW
@onready var timer_bar:TextureRect = %TimerBar
@onready var score_bar:TextureRect = %ScoreBar
@onready var win_label:Label = %WinLabel
@onready var lose_label:Label = %LoseLabel

var select_sound:AudioStream = preload("uid://cxg4q58es2u77")

var tick_timer:float = 0.0
var tween:Tween

func _ready() -> void:
    wheel.reset()
    wheel.zero_all_multipliers()
    tween = create_tween()
    timer_bar.custom_minimum_size.x = BAR_SIZE_TOTAL
    tween.tween_property(timer_bar, 'custom_minimum_size:x', 0, TIME)
    tween.finished.connect(_lose)

func _process(delta: float) -> void:
    tick_timer += delta
    if tick_timer > TICK_RATE and tween.is_running():
        tick_timer = 0.0
        _drain_slices()
        wheel.render()

# on choose
func _process_mash(_data:WheelSelectionData):
    wheel.get_selected_multiplier().value = min(wheel.get_selected_multiplier().value + TAP_VALUE, wheel.max_multiplier_value)
    _play_sound(select_sound)
    if _calculate_wheel_fullness() > SUCCESS_THRESHOLD:
        wheel.disable_all()
    wheel.render()
    if wheel.puzzle_finished():
        _win()

func _update_score_bar():
    if score_bar: score_bar.custom_minimum_size.x = min(BAR_SIZE_TOTAL, BAR_SIZE_TOTAL * (_calculate_wheel_fullness() / SUCCESS_THRESHOLD))

func _calculate_wheel_fullness() -> float:
    var maximum = len(wheel.multiplier_slice_data) * wheel.max_multiplier_value
    var total = 0
    for msd in wheel.multiplier_slice_data:
        total += msd.value
    return float(total) / maximum

func _drain_slices():
    for vsd_msd_pair in wheel.get_segments_with_matching_slices():
        var vsd:WheelSegmentData = vsd_msd_pair[0]
        var msd:WheelSliceData = vsd_msd_pair[1]
        msd.value = max(0, msd.value + vsd.value)

func _win():  
    tween.pause()
    win_label.show()
    await get_tree().create_timer(1.0).timeout
    var demo_control = get_node('/root/DemoRoot')
    if demo_control and demo_control is DemoControl:
        demo_control.change_scenes('Main Menu')

func _lose(): 
    wheel.disable_all()
    lose_label.show()
    await get_tree().create_timer(1.0).timeout
    var demo_control = get_node('/root/DemoRoot')
    if demo_control and demo_control is DemoControl:
        demo_control.change_scenes('Main Menu')

# thanks shane
func _play_sound(sound:AudioStream)->void:
    randomize()
    var player = AudioStreamPlayer.new()
    player.stream = sound
    player.pitch_scale = randf_range(1.05,1.15)
    player.volume_db = -4.0
    self.add_child(player)
    player.play()
    player.finished.connect(func():player.queue_free())

