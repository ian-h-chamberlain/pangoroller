extends Node

@export var player: Player

@onready var initial_player_transform: Transform3D = $Player.transform

func _process(_delta):
    if Input.is_action_just_pressed("quit") and OS.has_feature("pc"):
        print("exit requested")
        get_tree().quit()


func _on_world_boundary_body_exited(body: Node3D):
    if body == player:
        # Reset the player to start
        $Player.transform = initial_player_transform
        $Player.velocity = Vector3.ZERO
        $Player.begun = false
        $UI.timer_reset.emit()
        $UI.timer_pause.emit()
