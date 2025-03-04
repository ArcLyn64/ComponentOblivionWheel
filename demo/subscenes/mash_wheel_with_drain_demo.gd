extends CenterContainer

const BAR_SIZE_TOTAL:float = 500
const TIME:float = 10.0

@onready var wheel:ComponentWheel = %ComponentWheel
@onready var timer_bar:TextureRect = %TimerBar
@onready var score_bar:TextureRect = %ScoreBar
@onready var win_label:Label = %WinLabel
@onready var lose_label:Label = %LoseLabel

var select_sound:AudioStream = preload("uid://cxg4q58es2u77")

var tick_timer:float = 0.0
var tween:Tween

func _ready() -> void:
    wheel.reset()
    tween = create_tween()
    timer_bar.custom_minimum_size.x = BAR_SIZE_TOTAL
    tween.tween_property(timer_bar, 'custom_minimum_size:x', 0, TIME)
    tween.finished.connect(_lose)

func _update_score_bar():
    if score_bar: score_bar.custom_minimum_size.x = min(BAR_SIZE_TOTAL, BAR_SIZE_TOTAL * (wheel.puzzle_handler.wheel_fullness() / wheel.puzzle_handler.complete_threshold))

func _process(_delta: float) -> void:
    _update_score_bar()

# on choose
func _process_mash(_data:WheelSelectionData):
    DemoUtil.play_sound(self, select_sound)
            
func _win():  
    tween.pause()
    win_label.show()
    get_tree().create_timer(1.0).timeout.connect(_go_to_main_menu)

func _lose(): 
    wheel.disable_all_segments()
    lose_label.show()
    get_tree().create_timer(1.0).timeout.connect(_go_to_main_menu)

func _go_to_main_menu():
    var demo_control = get_node('/root/DemoRoot')
    if demo_control and demo_control is DemoControl:
        demo_control.change_scenes('Main Menu')
