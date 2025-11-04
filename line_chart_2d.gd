extends Node2D
# Real-time 2D line chart showing CPU temp1 (green) and temp3 (orange)
# Fixed Y range: 0 °C → 110 °C

@export var max_points: int = 200
@export var temp1_color: Color = Color(0, 1, 0)      # Green
@export var temp3_color: Color = Color(1, 0.3, 0)    # Orange
@export var line_width: float = 2.0
@export var padding: Vector2 = Vector2(0, 0)
@export var chart_rect: Rect2 = Rect2(Vector2(0, 0), Vector2(1152, 80))
@export var cpu_reader_path: NodePath = "/root/Node"

@export var axis_color: Color = Color(0, 0, 0,1)       # White axes
@export var grid_color: Color = Color(1, 1, 1, 0.2) # Semi-transparent white grid
@export var background_color: Color = Color(0, 0, 0, 1)  # Semi-transparent black background
@export var y_grid_step: float = 20.0                # Horizontal grid every 10 °C
@export var x_grid_step: int = 10                    # Vertical grid every 20 points

const MIN_TEMP: float = 0.0
const MAX_TEMP: float = 110.0

var data_temp1: Array[float] = []
var data_temp3: Array[float] = []

func _ready() -> void:
	var cpu_reader: Node = get_node_or_null(cpu_reader_path)
	if cpu_reader:
		cpu_reader.connect("temps_updated", Callable(self, "_on_temps_updated"))
	else:
		push_error("CPUReader node not found at path: %s" % cpu_reader_path)

# Handle signal: temps is a Dictionary { "temp1": x, "temp3": y }
func _on_temps_updated(temps: Dictionary) -> void:
	var t1: Variant = temps.get("temp1")
	var t3: Variant = temps.get("temp3")

	if t1 is float:
		data_temp1.append(t1)
		if data_temp1.size() > max_points:
			data_temp1.pop_front()

	if t3 is float:
		data_temp3.append(t3)
		if data_temp3.size() > max_points:
			data_temp3.pop_front()

	queue_redraw()

func _draw() -> void:
	if data_temp1.size() < 2 and data_temp3.size() < 2:
		return

	var rect: Rect2 = chart_rect

	# --- Draw background ---
	draw_rect(rect, background_color, true)

	# --- Draw grid ---
	_draw_grid(rect)

	# --- Draw border/axes ---
	draw_line(
		Vector2(rect.position.x + padding.x, rect.position.y + rect.size.y - padding.y),
		Vector2(rect.position.x + rect.size.x - padding.x, rect.position.y + rect.size.y - padding.y),
		axis_color, 1.0
	)
	draw_line(
		Vector2(rect.position.x + padding.x, rect.position.y + padding.y),
		Vector2(rect.position.x + padding.x, rect.position.y + rect.size.y - padding.y),
		axis_color, 1.0
	)

	# --- Draw temperature lines ---
	_draw_series(data_temp1, temp1_color, rect)
	_draw_series(data_temp3, temp3_color, rect)

# Draw horizontal and vertical grid lines
func _draw_grid(rect: Rect2) -> void:
	# Horizontal lines (temperature)
	var y_steps: int = int((MAX_TEMP - MIN_TEMP) / y_grid_step)
	for i in range(y_steps + 1):
		var temp_value: float = MIN_TEMP + i * y_grid_step
		var norm_y: float = (temp_value - MIN_TEMP) / (MAX_TEMP - MIN_TEMP)
		var y: float = rect.position.y + padding.y + (rect.size.y - padding.y * 2.0) * (1.0 - norm_y)
		draw_line(
			Vector2(rect.position.x + padding.x, y),
			Vector2(rect.position.x + rect.size.x - padding.x, y),
			grid_color, 1.0
		)

	# Vertical lines (time)
	for i in range(0, max_points, x_grid_step):
		var x: float = rect.position.x + padding.x + ((float(i) / float(max_points - 1)) * (rect.size.x - padding.x * 2.0))
		draw_line(
			Vector2(x, rect.position.y + padding.y),
			Vector2(x, rect.position.y + rect.size.y - padding.y),
			grid_color, 1.0
		)

# Draw a single temperature line
func _draw_series(data: Array[float], color: Color, rect: Rect2) -> void:
	if data.size() < 2:
		return

	var n: int = data.size()
	var points: PackedVector2Array = PackedVector2Array()

	for i in range(n):
		var x: float = rect.position.x + padding.x + ((float(i) / float(n - 1)) * (rect.size.x - padding.x * 2.0))
		var norm_y: float = clamp((data[i] - MIN_TEMP) / (MAX_TEMP - MIN_TEMP), 0.0, 1.0)
		var y: float = rect.position.y + padding.y + (rect.size.y - padding.y * 2.0) * (1.0 - norm_y)
		points.append(Vector2(x, y))

	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], color, line_width)
