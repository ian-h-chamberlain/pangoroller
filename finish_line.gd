extends Area3D

var times_finished = 0
@export var finish_direction = Vector3.RIGHT

signal finished()


# Called when the node enters the scene tree for the first time.
func _ready():
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D):
    if body is not Player:
        return

    # Very naive collision checking, assume we're always facing
    # A checkpoint system or something like that would be more robust
    if (body.position - self.position).dot(finish_direction) > 0:
        times_finished -= 1
    else:
        times_finished += 1

    print("collision detected, times finished: ", times_finished)

    if times_finished > 0:
        finished.emit()
