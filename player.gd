class_name Player
extends CharacterBody3D

@export var acceleration = 0.75
@export var braking_factor = 2
@export var friction = 0.1
@export var acceleration_direction =  Direction.EAST

signal direction_changed(new_direction: Direction)
signal accelerated(action_name: StringName, is_slowing: bool)
signal begin_play()

var begun = false

enum Direction {
    NORTH,
    EAST
}

const MOVEMENT_ACTIONS = ["movement_0", "movement_1", "movement_2", "movement_3"]

var last_action_index = null

@onready var direction_indicator = $DirectionIndicator as Node3D

func _physics_process(delta):
    if Input.is_action_just_pressed("reorient"):
        match self.acceleration_direction:
            Direction.NORTH:
                self.acceleration_direction = Direction.EAST
                direction_indicator.rotate(Vector3.UP, PI / 2)
            Direction.EAST:
                self.acceleration_direction = Direction.NORTH
                direction_indicator.rotate(Vector3.UP, PI / 2)

        direction_changed.emit(self.acceleration_direction == Direction.EAST)

        print("Changing acceleration_direction: ", self.acceleration_direction)

    if is_on_floor():
        if not begun:
            begun = true
            begin_play.emit()

        # Rotate the direction indicator to the correct axis, but use the floor surface
        # normal so it (mostly) doesn't clip through the floor.
        var look_direction: Vector3
        match self.acceleration_direction:
            Direction.NORTH:
                look_direction = Vector3.FORWARD
            Direction.EAST:
                look_direction = Vector3.RIGHT

        # Project the look direction onto the normal plane, and use that for our rotation
        look_direction = look_direction.slide(get_floor_normal());
        direction_indicator.transform = direction_indicator.transform.looking_at(look_direction, get_floor_normal())
    else:
        match self.acceleration_direction:
            Direction.NORTH:
                direction_indicator.rotation = Vector3.ZERO
            Direction.EAST:
                direction_indicator.rotation = Vector3(0, PI/2, 0)

    var speed_change = null
    for i in MOVEMENT_ACTIONS.size():
        if Input.is_action_just_pressed(MOVEMENT_ACTIONS[i]):
            # Only make any changes for adjacent keys being pressed (modulo # of keys)
            if last_action_index == null or i == posmod(last_action_index + 1,  MOVEMENT_ACTIONS.size()):
                speed_change = 1
            elif last_action_index == null or i == posmod(last_action_index - 1, MOVEMENT_ACTIONS.size()):
                speed_change = -1
            else:
                print("last index: ", last_action_index, ", current: ", i)
                # Accelerate towards v=0
                speed_change = 0

            last_action_index = i

            accelerated.emit(MOVEMENT_ACTIONS[i], speed_change == 0)

    if not is_on_floor():
        velocity += get_gravity() * delta
    elif speed_change == null:
        # This isn't really mathematically correct friction, but it's really just
        # meant to act as a way to dampen existing velocity after switching directions
        velocity -= velocity.normalized() * delta * friction
    else:
        match acceleration_direction:
            Direction.NORTH:
                if speed_change != 0:
                    velocity.z += acceleration * -speed_change
                else:
                    velocity.z += acceleration * -sign(velocity.z)
            Direction.EAST:
                if speed_change != 0:
                    velocity.x += acceleration * speed_change
                else:
                    velocity.x += acceleration * -sign(velocity.x)

    move_and_slide()
