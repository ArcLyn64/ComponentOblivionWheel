class_name DemoControl
extends Control

const ANIM_TIME = 0.3

@onready var subscenes:Dictionary = {
    'Main Menu': preload('uid://c1q5khwepbabi'),
    'Classic Wheel': preload('uid://dqrwxwpxgtylj'),
    'Mash to Fill': preload('uid://doswcbmdql5cy'),
    'Mash to Fill (Drain)': preload('uid://brn3assiyadxe'),
    'Chase the Wedge': preload('uid://dpa3e0ccbb2b6'),
    'Wheel as Play Area': preload('uid://c1q5khwepbabi'),
} 

@onready var subscene_container:Control = %SubsceneContainer
@onready var wheel_value_label:Label = %BaseValueDebugLabel
@onready var wheel_multiplier_label:Label = %MultiplierDebugLabel
@onready var wheel_data_label:Label = %WheelDataDebugLabel
@onready var selected_wheel_data_label:Label = %SelectedWheelDataDebugLabel
@onready var selected_index_and_position_label:Label = %SelectedIndexAndPositionDebugLabel

var background_music:AudioStream = preload("uid://0g3hbfl4uosc")
var select_sound:AudioStream = preload("uid://cxg4q58es2u77")
var rotate_sound:AudioStream = preload("uid://c43qhby2kqxxj")
var success_sound:AudioStream = preload("uid://bd4rwxqynrent")
var fail_sound:AudioStream = preload("uid://pcg4xnx3rd1t")

var bg_msc:AudioStreamPlayer

func _ready() -> void:
    _connect_wheel_signals()
    _update_debug()

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


func _get_active_scene_wheel():
    if not _get_active_scene() or not 'wheel' in _get_active_scene(): return
    return _get_active_scene().wheel


func _update_debug():
    var wheel:DROW = _get_active_scene_wheel()
    if not wheel: return
    wheel_value_label.text = '' if not wheel.get_selected_segment() else str(wheel.get_selected_segment().value)
    wheel_multiplier_label.text = '' if not wheel.get_selected_multiplier() else str(wheel.get_selected_multiplier().value)
    selected_index_and_position_label.text = '' if not wheel.selector_active else '%d/%d' % [wheel.selected_index, wheel.slice_position]
    selected_wheel_data_label.text = '' if not wheel.get_selected_segment() or not wheel.get_selected_multiplier() else '%d/%d' % [wheel.get_selected_segment().value, wheel.get_selected_multiplier().value]
    var data_array = []
    for msd_vsd_pair in wheel.get_segments_with_matching_slices():
        data_array.append([msd_vsd_pair[0].value, msd_vsd_pair[1].value])
    wheel_data_label.text = str(data_array)
    


func _connect_wheel_signals():
    var wheel:DROW = _get_active_scene_wheel()
    if not wheel.render_finished.is_connected(_update_debug):
        wheel.render_finished.connect(_update_debug)
    if not wheel.total_area_detector.mouse_exited.is_connected(_update_debug):
        wheel.total_area_detector.mouse_exited.connect(_update_debug)
    if not wheel.rotation_started.is_connected(_play_sound.bind(rotate_sound)):
        wheel.rotation_started.connect(_play_sound.bind(rotate_sound))
    if not wheel.new_segment_selected.is_connected(_play_sound.bind(select_sound)):
        wheel.new_segment_selected.connect(_play_sound.bind(select_sound))

# thanks shane
func _play_sound(sound:AudioStream)->void:
    randomize()
    var player = AudioStreamPlayer.new()
    player.stream = sound
    player.pitch_scale = randf_range(0.95,1.05)
    self.add_child(player)
    player.play()
    player.finished.connect(func():player.queue_free())

# thanks shane
func _play_music(music:AudioStream) -> void:
    if bg_msc == null:
        bg_msc = AudioStreamPlayer.new()
        self.add_child(bg_msc)
    bg_msc.stream = music
    bg_msc.pitch_scale = 1.02
    bg_msc.volume_db = -30
    bg_msc.play()
    bg_msc.finished.connect(func(): 
        await get_tree().create_timer(1.0).timeout
        _play_music(background_music)
    )
   
