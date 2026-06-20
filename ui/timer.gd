extends Label

var elapsed_msec: float = 0

var is_running = false

func _process(delta_seconds):
    if is_running:
        elapsed_msec += 1000 * delta_seconds
        var whole_min = int(elapsed_msec) / 60_000
        var sec = (elapsed_msec / 1000.0) - (whole_min * 60)
        self.text = "%d:%06.3f" % [whole_min, sec]

func _on_ui_timer_reset():
    elapsed_msec = 0
    is_running = true

func _on_ui_timer_pause():
    is_running = false;
