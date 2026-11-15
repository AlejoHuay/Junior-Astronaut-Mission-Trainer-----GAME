class_name BaseView
extends Control

var state: MissionState
var reduced_motion: bool = false
var arrival: float = 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(280, 280)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not reduced_motion:
		var tween := create_tween()
		tween.tween_method(func(value: float):
			arrival = value
			queue_redraw(), 0.0, 1.0, 0.7)
	else:
		arrival = 1.0
	resized.connect(queue_redraw)

func _draw() -> void:
	if state == null:
		return
	draw_style_box(_panel(Color("462e36")), Rect2(Vector2.ZERO, size))
	for i in range(18):
		var point := Vector2(fmod(float(i * 97 + 31), size.x), 30 + i * 13)
		draw_circle(point, 2.0, Color("916350"))
	var labels: Array[String] = ["PANELES", "HÁBITAT", "INVERNADERO", "REFUGIO"]
	var statuses: Array[String] = ["Averiados" if state.panel_fault else ("Polvo" if state.current_event == "dust" else "Operativos"), "Reforzado" if state.reinforced else "Sin refuerzo", "%d cuidados" % state.crop_progress, "En uso" if state.sheltered else "Disponible"]
	var font := ThemeDB.fallback_font
	var width := (size.x - 36) / 2.0
	for i in range(4):
		var origin := Vector2(12 + (i % 2) * (width + 12), 14 + (i / 2) * 130)
		var color := Color("35546a") if i < 2 else Color("345d51")
		draw_style_box(_panel(color), Rect2(origin, Vector2(width, 118)))
		draw_string(font, origin + Vector2(12, 24), labels[i], HORIZONTAL_ALIGNMENT_LEFT, width - 24, 17, Color.WHITE)
		draw_string(font, origin + Vector2(12, 102), statuses[i], HORIZONTAL_ALIGNMENT_LEFT, width - 24, 16, Color("eaf1f7"))
		var center := origin + Vector2(width / 2, 56)
		match i:
			0:
				for cell in range(6):
					draw_rect(Rect2(center + Vector2((cell % 3) * 17 - 24, (cell / 3) * 13 - 12), Vector2(14, 10)), Color("80c7ee"))
				if state.panel_fault:
					draw_line(center - Vector2(25, 20), center + Vector2(25, 20), Color("ffd18c"), 4)
			1:
				draw_rect(Rect2(center - Vector2(29, 17), Vector2(58, 34)), Color("d8e4e3"))
				for window in range(3):
					draw_circle(center + Vector2(window * 18 - 18, 0), 5, Color("35546a"))
			2:
				for plant in range(3):
					var bottom := center + Vector2(plant * 22 - 22, 16)
					var top := bottom - Vector2(0, 14 + state.crop_progress * 12)
					draw_line(bottom, top, Color("8bf0b4"), 3)
					draw_circle(top + Vector2(4, 0), 6, Color("8bf0b4"))
			3:
				draw_arc(center + Vector2(0, 14), 29, PI, TAU, 24, Color("c4b6a3"), 10)
				draw_rect(Rect2(center + Vector2(-9, -2), Vector2(18, 20)), Color("101c2c"))
		if not reduced_motion and arrival < 1.0:
			draw_circle(center + Vector2(-35 + arrival * 70, 26), 3, Color("ffe2a3"))
	if state.solar_alert:
		draw_style_box(_outline(), Rect2(Vector2(2, 2), size - Vector2(4, 4)))

func _panel(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(12)
	return style

func _outline() -> StyleBoxFlat:
	var style := _panel(Color.TRANSPARENT)
	style.border_color = Color("ffd18c")
	style.set_border_width_all(3)
	return style
