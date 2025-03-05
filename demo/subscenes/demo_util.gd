class_name DemoUtil
extends Resource

# thanks shane
static func play_sound(parent:Node, sound:AudioStream, volume:float = -4.0, pitch_scale:Vector2 = Vector2(0.95, 1.05))->void:
    randomize()
    var player = AudioStreamPlayer.new()
    player.stream = sound
    player.pitch_scale = randf_range(pitch_scale.x, pitch_scale.y)
    player.volume_db = volume
    parent.add_child(player)
    player.play()
    player.finished.connect(func():player.queue_free())

# thanks shane
static func play_music(bg_msc:AudioStreamPlayer, music:AudioStream) -> void:
    if bg_msc == null: return
    bg_msc.stream = music
    bg_msc.pitch_scale = 1.02
    bg_msc.volume_db = -30
    bg_msc.play()
    bg_msc.finished.connect(func(): 
        play_music(bg_msc, music)
    )
 