extends Area3D

## Which direction the player must pass through the finish line collider to
## be considered "completed".
@export var finish_direction = Vector3.RIGHT

signal finished_race()

var times_finished = 0


func _ready():
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D):
    if body is not Player:
        return

    # Very naive collision checking, assumes that the collision event fires
    # before the body has had a chance to move through space, and also requires
    # a hardcoded finish direction.
    #
    # A checkpoint system or something like that would be more robust here.
    if (body.position - self.position).dot(finish_direction) > 0:
        times_finished -= 1
    else:
        times_finished += 1

    if times_finished > 0:
        finished_race.emit()
