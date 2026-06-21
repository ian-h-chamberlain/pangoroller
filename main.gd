extends Node

@export var player: Player

@onready var initial_player_transform: Transform3D = $Player.transform


func _process(_delta):
    # Allow players to quit from desktop application easily
    if Input.is_action_just_pressed("quit") and OS.has_feature("pc"):
        print("exit requested")
        get_tree().quit()


func _on_world_boundary_body_exited(body: Node3D):
    if body == player:
        $Player.reset()
        $UI.timer_reset.emit()
        $UI.timer_pause.emit()
