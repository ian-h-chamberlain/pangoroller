extends CharacterBody3D

@export var acceleration_direction: Direction

enum Direction {
    NORTH,
    EAST
}

const ACCELERATION = 0.5

const MOVEMENT_ACTIONS = ["movement_0", "movement_1", "movement_2", "movement_3"]

var last_action_index = -1

@onready var direction_indicator = $DirectionIndicator as Node3D

func _physics_process(delta):
    if not is_on_floor():
        velocity += get_gravity() * delta

    if Input.is_action_just_pressed("reorient"):
        match self.acceleration_direction:
            Direction.NORTH:
                self.acceleration_direction = Direction.EAST
            Direction.EAST:
                self.acceleration_direction = Direction.NORTH

        print("Changing acceleration_direction: ", self.acceleration_direction)

    var speed_change = 0
    for i in MOVEMENT_ACTIONS.size():
        if Input.is_action_just_pressed(MOVEMENT_ACTIONS[i]):
            # Only make any changes for adjacent keys being pressed (modulo 4)
            # TODO: should we "cancel" movement if the keys are pressed out-of-order?
            # e.g. accelerate towards zero, or something like that

            if last_action_index == (i + 1) % MOVEMENT_ACTIONS.size():
                speed_change = -1
            elif last_action_index == (i - 1) % MOVEMENT_ACTIONS.size():
                speed_change = 1

            last_action_index = i

    match acceleration_direction:
        Direction.NORTH:
            if speed_change != 0:
                velocity.z += ACCELERATION * speed_change
            direction_indicator.rotation.y = 0
            direction_indicator.scale.z = -velocity.z
        Direction.EAST:
            if speed_change != 0:
                velocity.x += ACCELERATION * speed_change
            direction_indicator.rotation.y = PI / 2.0
            direction_indicator.scale.z = -velocity.x

    move_and_slide()
