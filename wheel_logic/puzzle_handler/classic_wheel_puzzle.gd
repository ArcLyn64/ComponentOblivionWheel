class_name ClassicWheelPuzzle
extends WheelPuzzle

var score = 0

func on_choice(data:WheelSelectionData):
    score += data.total_value
    wheel.disable_selected_segment()
    wheel.slices.rotate_right()
    await wheel.slices.rotation_finished
    if wheel.is_no_selectable_segments():
        wheel.puzzle_finished.emit()
