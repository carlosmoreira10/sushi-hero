extends AudioStreamPlayer3D

func _ready() -> void:
	play()

func _on_sfx_finished() -> void:
	queue_free()
