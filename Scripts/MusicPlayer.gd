extends AudioStreamPlayer

@onready var timer := Timer.new()

func _ready() -> void:
	add_child(timer)
	timer.connect("timeout", _start_music)
	self.connect("finished", _set_timer)
	_start_music()


func _set_timer() -> void:
	timer.one_shot = true
	timer.start(randi_range(20, 100))


func _start_music() -> void:
	play()
