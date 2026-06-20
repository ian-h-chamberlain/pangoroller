extends Camera3D

@export var player: Node3D

var pos_delta: Vector3

func _ready():
    pos_delta = player.position - self.position


# func _process(_delta):
#     self.position = player.position + self.pos_delta
