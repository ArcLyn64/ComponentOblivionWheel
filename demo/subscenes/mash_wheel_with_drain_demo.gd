extends CenterContainer

const BAR_SIZE_TOTAL:float = 500
const TIME:float = 10.0

@onready var wheel:ComponentWheel = %ComponentWheel
@onready var timer_bar:TextureRect = %TimerBar
@onready var score_bar:TextureRect = %ScoreBar
@onready var win_label:Label = %WinLabel
@onready var lose_label:Label = %LoseLabel

var success_sound:AudioStream = preload('uid://cw8khym1e68s7')
var fail_sound:AudioStream = preload('uid://ix7ju3r8xufo')
var select_sound:AudioStream = preload("uid://bk1oyixl520ef")
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
    DemoUtil.play_sound(self, select_sound, -5, Vector2(1.05, 1.15))
            
func _win():  
    tween.pause()
    win_label.show()
    DemoUtil.play_sound(self, success_sound, -20)
    get_tree().create_timer(1.0).timeout.connect(_go_to_main_menu)

func _lose(): 
    wheel.disable_all_segments()
    lose_label.show()
    DemoUtil.play_sound(self, fail_sound, -15)
    get_tree().create_timer(1.0).timeout.connect(_go_to_main_menu)

func _go_to_main_menu():
    var demo_control = get_node('/root/DemoRoot')
    if demo_control and demo_control is DemoControl:
        demo_control.change_scenes('Main Menu')
