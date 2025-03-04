class_name DemoUtil
extends Resource

# thanks shane
static func play_sound(parent:Node, sound:AudioStream)->void:
    randomize()
    var player = AudioStreamPlayer.new()
    player.stream = sound
    player.pitch_scale = randf_range(1.05,1.15)
    player.volume_db = -4.0
    parent.add_child(player)
    player.play()
    player.finished.connect(func():player.queue_free())

