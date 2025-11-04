extends Label

func _ready():
	var cpu_reader = get_node("/root/Node")  # adjust path if needed
	if cpu_reader:
		cpu_reader.connect("temps_updated", Callable(self, "_on_temps_updated"))
	else:
		push_error("CPUReader node not found!")

func _on_temps_updated(temps: Dictionary) -> void:
	# Get CPU temperature (temp3 = Tctl)
	var temp = temps.get("temp1", null)
	if temp != null:
		text = "%.1f°C" % temp
	else:
		text = "-- °C"
