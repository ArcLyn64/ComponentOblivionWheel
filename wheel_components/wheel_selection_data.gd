class_name WheelSelectionData
extends Resource

## Index of the selected wheel position
var selection_index:int
## Current rotation position of the multiplier slices
var slice_position:int
## Base value of the selected wheel segment
var base_value:int
## Multiplier value of the overlapping wheel slice
var multiplier:int
## Total value of this selection (base_value * multiplier)
var total_value:int