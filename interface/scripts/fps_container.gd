extends ColorRect
class_name Fps

@export_category("Objects")
@export var _fps: Label = null

func _physics_process(_delta: float) -> void:#executado a cada frame
	_fps.text = str(Engine.get_frames_per_second()) + "- FPS"
