extends CenterContainer

const BAR_SIZE_TOTAL:float = 500
const TIME:float = 10.0
const SUCCESS_THRESHOLD:int = 20
const CHANCE_TO_ROTATE:float = 0.3

@onready var wheel:DROW = %DROW
@onready var timer_bar:TextureRect = %TimerBar
@onready var score_bar:TextureRect = %ScoreBar
@onready var win_label:Label = %WinLabel
@onready var lose_label:Label = %LoseLabel

var select_sound:AudioStream = preload("uid://cxg4q58es2u77")

var score:int = 0 :
    set(v):
        score = max(0, v)
var tween:Tween

func _ready() -> void:
    wheel.reset()
    tween = create_tween()
    timer_bar.custom_minimum_size.x = BAR_SIZE_TOTAL
    tween.tween_property(timer_bar, 'custom_minimum_size:x', 0, TIME)
    tween.finished.connect(_lose)

# on choose
func _process_mash(data:WheelSelectionData):
    score += data.total_value
    _play_sound(select_sound)
    if score > SUCCESS_THRESHOLD:
        wheel.disable_all()
    if randf() < CHANCE_TO_ROTATE:
        if randf() < 0.5:
            wheel.rotate_left()
        else:
            wheel.rotate_right()
    wheel.render()
    if wheel.puzzle_finished():
        _win()

func _update_score_bar():
    if score_bar: score_bar.custom_minimum_size.x = min(BAR_SIZE_TOTAL, BAR_SIZE_TOTAL * (float(score) / SUCCESS_THRESHOLD))

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

