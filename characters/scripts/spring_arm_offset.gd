extends Node3D
class_name SpringArmCharacter

const _MOUSE_SENSIBILITY: float = 0.005

var can_rotate: bool = true

@export_category("Objects")
@export var _spring_arm: SpringArm3D = null

#capta todos eventos de input
func _unhandled_input(_event) -> void:
	if not can_rotate:
		return
	
	if _event is InputEventMouseMotion:
		rotate_y(-_event.relative.x * _MOUSE_SENSIBILITY)
		_spring_arm.rotate_x(-_event.relative.y * _MOUSE_SENSIBILITY)
		_spring_arm.rotation.x = clamp(_spring_arm.rotation.x, -PI/4, PI/24)#campo de visao da rotacao, min , max

