extends Camera3D

@export var direction: Player.Direction = Player.Direction.EAST
@export var target_distance: float = 6
@export var target_height: float = 6

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
