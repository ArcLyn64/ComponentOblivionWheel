class_name MashWheelPuzzle
extends WheelPuzzle

@export var value_per_tick:int = 1
@export var disable_on_full:bool = true
## How fast we drain progress from the slices (0-60). 
## if 0, disables drain.
@export_range(0, 60) var tick_rate:int = 12 :
    set(v): tick_rate = clampi(v, 0, 60)
@export_range(0, 1, 0.01) var complete_threshold:float = 1

var tick_timer = 0 

func on_choice(data:WheelSelectionData):
    wheel.slices.set_multiplier_at(data.selection_index,  min(data.multiplier + value_per_tick, wheel.slices.max_value))
    if disable_on_full and wheel.get_selected_multiplier() >= wheel.slices.max_value:
        wheel.disable_selected_segment()
    if wheel.is_no_selectable_segments():
        wheel.puzzle_finished.emit()
    if wheel_fullness() > complete_threshold:
        wheel.disable_all_segments()
        wheel.puzzle_finished.emit()

func on_process(delta:float):
    if tick_rate == 0: return

    tick_timer += delta
    if tick_timer > (1.0 / tick_rate):
        tick_timer = 0.0
        _drain_slices()

func _drain_slices():
    for index in wheel.segments.num_segments:
        if not wheel.covers.is_index_selectable(index): continue # don't drain deactivated segments
        var value = wheel.segments.get_value_at(index)
        wheel.slices.set_multiplier_at(index, max(0, wheel.slices.get_multiplier_at(index) + value))

func wheel_fullness() -> float:
    var maximum = wheel.slices.num_slices * wheel.slices.max_value
    var total = 0
    for i in wheel.slices.num_slices:
        total += wheel.slices.get_multiplier_at(i)
    return float(total) / maximum

func reset():
    super()
    wheel.zero_all_multipliers()
