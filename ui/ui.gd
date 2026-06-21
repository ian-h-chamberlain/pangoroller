extends Control

signal player_accelerated(action_name: StringName, is_slowing: bool)
signal direction_changed(direction: Player.Direction)
signal timer_reset()
signal timer_pause()

func _ready():
    # Wire up the various input actions to be displayed in the UI
    for child in $Header/Keys.get_children():
        var indicator = child as KeyIndicator
        if indicator:
            player_accelerated.connect(indicator.on_player_accelerated)


func _on_player_accelerated(action_name: StringName, is_slowing: bool):
    player_accelerated.emit(action_name, is_slowing)


func _on_player_direction_changed(direction: Player.Direction):
    direction_changed.emit(direction)


func _on_player_begin_play():
    timer_reset.emit()


func _on_finish_line_finished_race():
    timer_pause.emit()
