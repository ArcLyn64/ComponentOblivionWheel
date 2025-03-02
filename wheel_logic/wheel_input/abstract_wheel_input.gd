class_name WheelInput
extends Resource

@export var input_enabled:bool = true

var wheel:ComponentWheel

func attach_wheel(wheel_:ComponentWheel):
    wheel = wheel_ ## This can be overridden to add things like signal connections needed for function

func handle_input(_event: InputEvent):
    pass ## This can be overridden to handle inputevents needed for function