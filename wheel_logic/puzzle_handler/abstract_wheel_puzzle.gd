class_name WheelPuzzle
extends Resource

var wheel:ComponentWheel

func attach_wheel(wheel_:ComponentWheel):
    ## This can be overridden to add things like signal connections needed for function
    wheel = wheel_
    wheel.new_segment_selected.connect(on_selection)
    wheel.new_segment_chosen.connect(on_choice)

func on_selection():
    pass

func on_choice(_choice_data:WheelSelectionData):
    pass

func on_process(_delta:float):
    pass

func reset():
    wheel.segments.shuffle_values()
    wheel.slices.shuffle_multipliers()
    wheel.enable_all_segments()