class_name DemoControl
extends Control

const ANIM_TIME = 0.3

@onready var subscenes:Dictionary = {
    'Main Menu': preload('uid://c1q5khwepbabi'),
    'Classic Wheel': preload('uid://dqrwxwpxgtylj'),
    'Mash to Fill': preload('uid://doswcbmdql5cy'),
    'Mash to Fill (Drain)': preload('uid://brn3assiyadxe'),
    'Chase the Wedge': preload('uid://dpa3e0ccbb2b6'),
    'Wheel as Play Area': preload('uid://1s3qqbc0ubl3'),
} 

@onready var subscene_container:Control = %SubsceneContainer
@onready var wheel_value_label:Label = %BaseValueDebugLabel
@onready var wheel_multiplier_label:Label = %MultiplierDebugLabel
@onready var wheel_data_label:Label = %WheelDataDebugLabel
@onready var selected_wheel_data_label:Label = %SelectedWheelDataDebugLabel
@onready var selected_index_and_position_label:Label = %SelectedIndexAndPositionDebugLabel

var background_music:AudioStream = preload("uid://qunbssm1x4u1")
var select_sound:AudioStream = preload("uid://bk1oyixl520ef")
var rotate_sound:AudioStream = preload('uid://5pp47qq4qsxq')

var bg_msc:AudioStreamPlayer

func _ready() -> void:
    bg_msc = AudioStreamPlayer.new()
    add_child(bg_msc)
    _connect_wheel_signals()
    _update_debug()
    DemoUtil.play_music(bg_msc, background_music)

func change_scenes(scene:StringName):
    if not scene in subscenes.keys(): return
    _get_active_scene().process_mode = Node.PROCESS_MODE_DISABLED
    var tween = create_tween()
    tween.tween_property(subscene_container, 'modulate:a', 0, ANIM_TIME).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
    await tween.finished
    _get_active_scene().queue_free()
    var next_scene = subscenes[scene].instantiate()
    subscene_container.add_child(next_scene)
    next_scene.process_mode = PROCESS_MODE_DISABLED
    await get_tree().create_timer(0.5).timeout
    tween = create_tween()
    tween.tween_property(subscene_container, 'modulate:a', 1, ANIM_TIME).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
    await tween.finished
    next_scene.process_mode = PROCESS_MODE_INHERIT
    _connect_wheel_signals()
    _update_debug()


func _get_active_scene():
    if not subscene_container or subscene_container.get_child_count() < 1: return null
    return subscene_container.get_child(0)


func _get_active_scene_wheel() -> ComponentWheel:
    if not _get_active_scene() or not 'wheel' in _get_active_scene(): return null
    return _get_active_scene().wheel


func _update_debug():
    var wheel:ComponentWheel = _get_active_scene_wheel()
    if not wheel: return
    wheel_value_label.text = '' if not wheel.is_selector_active() else str(wheel.get_selected_value())
    wheel_multiplier_label.text = '' if not wheel.is_selector_active() else str(wheel.get_selected_multiplier())
    selected_index_and_position_label.text = '' if not wheel.is_selector_active() else '%d/%d' % [wheel.get_selected_index(), wheel.slices.position_index]
    selected_wheel_data_label.text = '' if not wheel.is_selector_active() else '%d/%d' % [wheel.get_selected_value(), wheel.get_selected_multiplier()]
    var data_array:Array[Array] = []
    for i in wheel.segments.num_segments:
        data_array.append([wheel.segments.get_value_at(i), wheel.slices.get_multiplier_at(i)])
    wheel_data_label.text = str(data_array)
    
func _connect_wheel_signals():
    var wheel:ComponentWheel = _get_active_scene_wheel()
    if not wheel.slices.rotation_started.is_connected(DemoUtil.play_sound.bind(self, rotate_sound)):
        wheel.slices.rotation_started.connect(DemoUtil.play_sound.bind(self, rotate_sound))
    if not wheel.new_segment_selected.is_connected(DemoUtil.play_sound.bind(self, select_sound)):
        wheel.new_segment_selected.connect(DemoUtil.play_sound.bind(self, select_sound))
  
func _process(_delta: float) -> void:
    _update_debug()
