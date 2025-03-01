@tool
class_name ComponentWheel
extends Control
######################
# region Export Vars
######################
@export_group('Logic')
# @export var input_handler:WheelInput
# @export var puzzle_handler:WheelPuzzle
@export_group('Components')
@export var slices:WheelSlices
@export var segments:WheelSegments
@export var overlay:Control
@export var covers:WheelCovers
# @export var selector:WheelSelector
#endregion