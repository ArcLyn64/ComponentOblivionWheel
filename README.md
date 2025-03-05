# COW - The Component Oblivion Wheel

## How to COW
### I want the w h e e l
Drop the ComponentOblivionWheel folder into your godot project. Then 
After you're done examining the demo files, you are free to delete the demo folder.

### How do I change things?
Tweak the exports! Most aspects of the wheel can me messed with that way, from the colors, to the point values, to the logic of the puzzle, to the number of segments!
The demo contains six examples of wheel usage for you to get an idea of what that looks like.

### What if the default functionality isn't enough?
You can assign each of the wheel's components to either one of the included pieces or one you define on your own with the same functionality. 
For the segments, slices, and covers I'd recommend making a new template for the individual slices/segments/whatever over making a new wheel_slices class unless it's lacking functionality you need.
The difference between rendered_wheel_slice and texture_wheel_slice is a design example of this paradigm

Custom selectors must keep track of the number of valid wheel segments as well as the selected segment to be valid
Custom overlays effectively don't need to do anything, but can take a radius param to auto-resize.

## Can I use this for my thing
yea. lmk if you do though!

## Hi your thing is broken
oh dear. please feel free to file an issue via github and i'll see about it.

## Where is that super cool wheel texture from it's awesome
[here!!](https://larscandybars.itch.io/wheeljam-2025-template-assets)

## This thing seems overkill
yea. there is a simpler and better template you can use [here](https://github.com/shaner421/the-wheel-godot)
