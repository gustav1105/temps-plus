extends Sprite2D

@export var rotation_min_deg: float = 70.0
@export var rotation_max_deg: float = 245.0
@export var temp_max: float = 110.0
@export var tween_duration: float = 0.3  # seconds

var _target_rotation: float = 0.0
var _tween: Tween

func _ready():
	var cpu_reader = get_node("/root/Node")  # adjust as needed
	if cpu_reader:
		cpu_reader.connect("temps_updated", Callable(self, "_on_temps_updated"))
	else:
		push_error("CPUReader node not found!")

func _on_temps_updated(temps: Dictionary) -> void:
	var temp = temps.get("temp1", 0)
	var normalized = clamp(temp / temp_max, 0, 1)
	var angle_deg = lerp(rotation_min_deg, rotation_max_deg, normalized)
	_target_rotation = deg_to_rad(angle_deg)
	_smooth_rotate_to_target()

func _smooth_rotate_to_target() -> void:
	if _tween and _tween.is_running():
		_tween.kill()  # stop any previous tween

	_tween = create_tween()
	_tween.tween_property(self, "rotation", _target_rotation, tween_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
