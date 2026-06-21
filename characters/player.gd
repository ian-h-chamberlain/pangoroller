class_name Player
extends CharacterBody3D

## Acceleration of the player controller slide motion.
@export var acceleration = 0.75
## Coefficient of deceleration when "rolling" inputs are not pressed in order.
@export var braking_factor = 2
## Approximates a coefficient of friction (not physically accurate).
@export var friction = 0.1
## How fast to interpolate the directional indicator to its target position.
@export var indicator_speed = 5.0

## The current axis that the player is controlling.
@export var acceleration_axis = Direction.EAST:
    set(v):
        if v != acceleration_axis:
            direction_changed.emit(v)
        acceleration_axis = v

## Emitted whenever the player presses the "change direction" action.
signal direction_changed(new_direction: Direction)
## Emitted when a user input for one of the four "motion" keys is pressed.
signal accelerated(action_name: StringName, is_slowing: bool)
## Emitted when play starts (i.e. to start the clock).
signal begin_play()

var started_playing = false:
    set(v):
        if v and not started_playing:
            begin_play.emit()
        started_playing = v

@onready var direction_indicator = $DirectionIndicator as Node3D
@onready var initial_transform = self.transform
@onready var indicator_initial_transform = $DirectionIndicator.transform

const MOVEMENT_ACTIONS = ["movement_0", "movement_1", "movement_2", "movement_3"]
var last_action_index = null

enum Direction {
    NORTH,
    EAST,
}


## Move the player back to starting position, reset timers, orientation etc.
func reset():
    transform = initial_transform
    velocity = Vector3.ZERO
    started_playing = false
    direction_indicator.transform = indicator_initial_transform
    acceleration_axis = Direction.EAST


func _physics_process(delta):
    if Input.is_action_just_pressed("reorient"):
        _change_orientation()

    if is_on_floor():
        # Don't start timer logic etc. until we've hit the ground for the first time
        if not started_playing:
            started_playing = true

        _update_direction_indicator(delta)

        var velocity_change := _handle_movement_input()
        if velocity_change == Vector3.ZERO:
            # This isn't really mathematically correct friction, but it's really just
            # meant to act as a way to dampen existing velocity after switching directions
            velocity -= velocity.normalized() * delta * friction
        else:
            velocity += velocity_change
    else:
        # User input / friction has no effect when in the air
        velocity += get_gravity() * delta

    # Run the builtin character controller physics handler
    move_and_slide()

    # Give the appearance of rolling, but we don't actually need to change our collider,
    # so we can just rotate the mesh. This also prevents the other children from being rotated
    # (e.g. direction indicators, camera)
    var axis = velocity.cross(Vector3.DOWN).normalized()
    if axis != Vector3.ZERO:
        $PlayerMesh.rotate(axis, delta * velocity.length() / PI)


## Toggle the axis the player is accelerating along
func _change_orientation() -> void:
    var angle = PI / 2

    match self.acceleration_axis:
        Direction.NORTH:
            self.acceleration_axis = Direction.EAST
            angle *= -1.0
        Direction.EAST:
            self.acceleration_axis = Direction.NORTH

    direction_indicator.rotate(Vector3.UP, angle)


## Reorient the directional indicator according to the current acceleration axis.
## The floor normal is used to help prevent too much clipping of the arrows into the floor.
func _update_direction_indicator(delta: float) -> void:
    var look_direction = _direction_to_vector(self.acceleration_axis)

    # Project the look direction onto the normal plane, and use that for indicator's rotation
    look_direction = look_direction.slide(get_floor_normal())
    var target_transform = direction_indicator.transform.looking_at(look_direction, get_floor_normal())
    direction_indicator.transform = direction_indicator.transform.interpolate_with(target_transform, indicator_speed * delta)


## Check for "rolling" movement on the keyboard; returns a normalized direction vector
## which indicates which way to apply acceleration.
func _handle_movement_input() -> Vector3:
    var accel_direction := Vector3.ZERO

    # Check all the inputs
    for i in MOVEMENT_ACTIONS.size():
        if Input.is_action_just_pressed(MOVEMENT_ACTIONS[i]):
            var is_slowing := false

            if last_action_index == null:
                last_action_index = i
                break

            # Only make any changes for adjacent keys being pressed (modulo # of keys)
            if i == posmod(last_action_index + 1, MOVEMENT_ACTIONS.size()):
                accel_direction = _direction_to_vector(acceleration_axis) * acceleration
            elif i == posmod(last_action_index - 1, MOVEMENT_ACTIONS.size()):
                accel_direction = -_direction_to_vector(acceleration_axis) * acceleration
            else:
                # The player "messed up", accelerate towards v=0
                accel_direction = -velocity.normalized() * braking_factor
                is_slowing = true

            last_action_index = i
            accelerated.emit(MOVEMENT_ACTIONS[i], is_slowing)
            break

    return accel_direction


## Convert Direction to a world-space axis vector.
static func _direction_to_vector(direction: Direction) -> Vector3:
    match direction:
        Direction.EAST:
            return Vector3.RIGHT
        Direction.NORTH:
            return Vector3.FORWARD

    assert(false, "unexpected direction %s" % direction)
    return Vector3.ZERO
