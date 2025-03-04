extends CenterContainer

const BAR_SIZE_TOTAL:float = 500
const INDICATOR_COLORS:Dictionary = {
    -2: Color.RED,
    -1: Color.YELLOW,
    0: Color.WHITE,
    1: Color.DEEP_SKY_BLUE,
    2: Color.GREEN
}
const MAX_SCORE_MAGNITUDE = 12 ## 8 + 4 is the highest a score can get on a regular ol wheel

@onready var wheel:ComponentWheel = %ComponentWheel
@onready var indicator_rect:TextureRect = %IndicatorRect
@onready var good_bar:ColorRect = %GoodBar
@onready var bad_bar:ColorRect = %BadBar
@onready var win_label:Label = %WinLabel
@onready var lose_label:Label = %LoseLabel

func _ready() -> void:
    wheel.segments.segment_area.mouse_exited.connect(func(): indicator_rect.modulate = INDICATOR_COLORS[0])
    wheel.reset()

func _update_on_selection():
    indicator_rect.modulate = INDICATOR_COLORS[wheel.get_selected_value()]

func _handle_choice(_data:WheelSelectionData):
    # update score bar display
    call_deferred('_update_score_bar')

func _update_score_bar():
    var score = wheel.puzzle_handler.score
    good_bar.custom_minimum_size.x = BAR_SIZE_TOTAL * (MAX_SCORE_MAGNITUDE + score)/(2 * MAX_SCORE_MAGNITUDE)
    bad_bar.custom_minimum_size.x = BAR_SIZE_TOTAL * (MAX_SCORE_MAGNITUDE - score)/(2 * MAX_SCORE_MAGNITUDE)

func _handle_finished_puzzle():
    var score = wheel.puzzle_handler.score
    if score > 0:
        win_label.show()
    else:
        lose_label.show()
    await get_tree().create_timer(1.0).timeout
    var demo_control = get_node('/root/DemoRoot')
    if demo_control and demo_control is DemoControl:
        demo_control.change_scenes('Main Menu')
