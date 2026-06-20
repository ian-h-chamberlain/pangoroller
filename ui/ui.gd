extends Control

signal player_accelerated(action_name: StringName, is_slowing: bool)

func _ready():
    for child in $Keys.get_children():
        var indicator = child as KeyIndicator
        if indicator:
            player_accelerated.connect(indicator.on_player_accelerated)

func _on_player_accelerated(action_name: StringName, is_slowing: bool):
    player_accelerated.emit(action_name, is_slowing)
