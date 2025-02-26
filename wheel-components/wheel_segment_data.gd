class_name WheelSegmentData
extends Resource

## Segment color acts like a color filter, not additive light.
@export var color:Color = Color.WHITE
## Base value for this segment.
@export var value:int = 1
## Whether or not this segment is selectable (if false, displays the cover for this segment).
@export var selectable:bool = true ## TODO: take this outta here and make it an array within DROW so it's accessible from different places