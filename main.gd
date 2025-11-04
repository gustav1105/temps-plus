extends Node

signal temps_updated(temps)

var cpu_sensor
var latest_temps = {}

func _ready():
	cpu_sensor = Test.new()
	add_child(cpu_sensor)

	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	if cpu_sensor:
		latest_temps = cpu_sensor.get_cpu_temps()
		#print("CPU Temps: ", latest_temps)
		emit_signal("temps_updated", latest_temps)
