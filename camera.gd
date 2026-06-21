extends Camera3D

## The axis the player is currently controlling.
@export var direction: Player.Direction = Player.Direction.EAST
## Horizontal distance from the player the camera should be.
@export var target_distance: float = 6
## Height from the player the camera should be.
@export var target_height: float = 6
## How fast to move the camera between targets (e.g. when direction changes).
@export var speed: float = 2

func _process(delta):
    var target = Vector3(0, target_height, 0)

    match direction:
        Player.Direction.EAST:
            target.z = target_distance
        Player.Direction.NORTH:
            target.x = target_distance

    # Lerp towards the target position
    position = position.lerp(target, delta * speed)
    look_at(get_parent().position)

func _on_player_direction_changed(new_direction):
    direction = new_direction
