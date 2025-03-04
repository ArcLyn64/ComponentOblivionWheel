class_name ChaseTheWedgePuzzle
extends WheelPuzzle

@export var target:int = 20
@export var chance_to_rotate:float = 0.25

var score = 0 :
    set(v):
        score = max(0, v)

func on_choice(data:WheelSelectionData):
    score += data.total_value
    if score > target:
        wheel.disable_all_segments()
        wheel.puzzle_finished.emit()
    if randf() < chance_to_rotate:
        if randf() < 0.5:
            wheel.slices.rotate_left()
        else:
            wheel.slices.rotate_right()

func reset():
    super()
    score = 0