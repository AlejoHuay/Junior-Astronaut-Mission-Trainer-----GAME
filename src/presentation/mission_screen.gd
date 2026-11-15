extends Control

const INK := Color("101c2c")
const PAPER := Color("eaf1f7")
const MUTED := Color("a8bdce")
const ACCENT := Color("74e0c2")

var science_catalog: Dictionary
var science_provider := ScienceData.new()
var session: MissionSession
var content: VBoxContainer
var status: Label
var selected_action: String = "support"
var action_picker: OptionButton
var action_detail: Label
var action_preview: Label
var execute_button: Button
var scenario_picker: OptionButton
var scenario_description: Label
var log_text: Label
var seed_input: SpinBox

func _ready() -> void:
	_setup_theme()
	science_catalog = science_provider.load_catalog()
	var provider := GameData.new()
	var config := provider.load_balance()
	if config.is_empty():
		_label(self, provider.error, 24)
		return
	session = MissionSession.new(config)
	session.changed.connect(_show_mission)
	session.message.connect(func(text: String): status.text = text)
	_show_menu()

func _setup_theme() -> void:
	var custom := Theme.new()
	custom.default_font_size = 19
	custom.set_color("font_color", "Label", PAPER)
	custom.set_color("font_color", "Button", PAPER)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("243b50") if state != "hover" else Color("365970")
		style.set_corner_radius_all(12)
		style.content_margin_left = 18
		style.content_margin_right = 18
		style.content_margin_top = 12
		style.content_margin_bottom = 12
		if state == "focus":
			style.bg_color = Color.TRANSPARENT
			style.border_color = ACCENT
			style.set_border_width_all(3)
		custom.set_stylebox(state, "Button", style)
	theme = custom

func _page() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 28)
	scroll.add_child(margin)
	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)
	_label(content, "JUNIOR ASTRONAUT   /   CONTROL DE MISIÓN", 17, ACCENT)

func _show_menu() -> void:
	_page()
	_label(content, "Tu primera base.\nUn gran reto en Marte.", 48)
	_label(content, "Mantén la base durante 7 soles: un sol es un día marciano.\nCada sol eliges un trabajo. Antes de decidir, mira tus reservas y el costo.", 24)
	_label(content, "La energía mueve los sistemas. El oxígeno y la comida se consumen cada sol.\nInvestigar suma hallazgos, pero también necesitas tiempo para cuidar la base.", 21, MUTED)
	seed_input = SpinBox.new()
	seed_input.min_value = 1
	seed_input.max_value = 999999
	seed_input.value = 214
	seed_input.prefix = "Semilla de misión: "
	content.add_child(seed_input)
	scenario_picker = OptionButton.new()
	scenario_picker.custom_minimum_size.y = 48
	content.add_child(scenario_picker)
	for scenario_id in session.rules.config.scenarios:
		scenario_picker.add_item(session.rules.config.scenarios[scenario_id].label)
		scenario_picker.set_item_metadata(scenario_picker.item_count - 1, scenario_id)
		if scenario_id == "demo":
			scenario_picker.select(scenario_picker.item_count - 1)
	scenario_description = _label(content, "", 19, MUTED)
	scenario_picker.item_selected.connect(_scenario_selected)
	_scenario_selected(scenario_picker.selected)
	var start_button := _button(content, "Comenzar misión  →", func():
		selected_action = "support"
		session.start(int(seed_input.value), str(scenario_picker.get_item_metadata(scenario_picker.selected))))
	start_button.grab_focus()
	_button(content, "Fuentes y créditos", _show_sources)
	_label(content, "Simulación educativa • Sin cuentas • Sin conexión durante la partida", 17, MUTED)

func _scenario_selected(index: int) -> void:
	var id: String = scenario_picker.get_item_metadata(index)
	scenario_description.text = session.rules.config.scenarios[id].description

func _show_mission() -> void:
	_page()
	var state := session.state
	_label(content, "SOL %d / 7 · %s · Semilla %d" % [state.sol, session.rules.config.scenarios[state.scenario_id].label, state.mission_seed], 28)
	_label(content, "ENERGÍA  %d / %d     |     OXÍGENO  %d     |     ALIMENTOS  %d" % [state.energy, session.rules.config.battery_capacity, state.oxygen, state.food], 26, ACCENT)
	_label(content, "Opcionales: hallazgos %d / %d · Muestras exteriores %d / 1. Sobrevivir completa la misión." % [state.science, session.rules.config.science_goal, state.samples], 17, MUTED)
	var science_id: String = session.rules.config.scenarios[state.scenario_id].get("science_id", "")
	if not science_id.is_empty():
		_label(content, "Contexto histórico DONKI · 10 mayo 2024. Alerta y efectos marcianos ficticios; consulta Fuentes.", 17, MUTED)
	var event: Dictionary = session.rules.config.events[state.current_event]
	_label(content, "ENTORNO · %s — %s%s" % [event.label, event.description, "\n¡Mañana hay alerta solar! Prepara protección." if state.next_solar_alert else ""], 18, ACCENT)
	var radio_text := state.radio_message if not state.radio_message.is_empty() else "Sin consulta enviada. Una respuesta tarda %d soles simulados." % session.rules.config.communication_delay
	_label(content, "RADIO · " + radio_text, 18, MUTED)
	_label(content, "BASE · %s · Materiales %d · Paneles: %s" % ["Interior reforzado" if state.reinforced else "Refugio listo; interior sin refuerzo", state.materials, "averiados" if state.panel_fault else "operativos"], 18, MUTED)
	_label(content, "CULTIVO · %d / %d cuidados consecutivos → +%d comida. Tiempo acelerado ficticio; otra tarea pierde el progreso." % [state.crop_progress, session.rules.config.crop_turns, session.rules.config.harvest_food], 18, MUTED)
	status = _label(content, "Consumo base: oxígeno −%d, comida −%d · Solar disponible: %d. Vista previa solo del sol actual." % [session.rules.config.oxygen_per_sol, session.rules.config.food_per_sol, maxi(0, state.solar_output - (int(session.rules.config.panel_fault_loss) if state.panel_fault else 0))], 18)
	if state.phase == MissionState.Phase.FINISHED:
		_label(content, state.outcome, 28)
		var result := session.rules.summary(state)
		_label(content, "Objetivos opcionales: ciencia %s · muestra exterior %s.\nCosechaste %d alimentos; interrumpiste %d cultivo(s); usaste refugio %d sol(es).\nConsejos aún pendientes al finalizar: %d. No se adelantan ni llegan suministros." % ["lograda" if result.science_goal else "pendiente", "lograda" if result.sample_goal else "pendiente", result.harvested, result.interruptions, result.shelter_turns, result.pending_count], 20, MUTED)
		_button(content, "Volver a planear", _show_menu).grab_focus()
	else:
		_label(content, "1. ELIGE UN PLAN   ·   2. REVISA   ·   3. EJECUTA", 18, ACCENT)
		action_picker = OptionButton.new()
		action_picker.custom_minimum_size.y = 48
		content.add_child(action_picker)
		for action_id in session.rules.config.actions:
			var action: Dictionary = session.rules.config.actions[action_id]
			var check := session.rules.preview(state, action_id)
			action_picker.add_item(action.label + (" · no disponible" if not check.ok else ""))
			action_picker.set_item_metadata(action_picker.item_count - 1, action_id)
			if action_id == selected_action:
				action_picker.select(action_picker.item_count - 1)
		action_detail = _label(content, "", 18, MUTED)
		action_preview = _label(content, "", 18, ACCENT)
		var expected_sol: int = state.sol
		execute_button = _button(content, "Ejecutar plan y terminar sol →", func(): session.choose(selected_action, expected_sol))
		action_picker.item_selected.connect(_action_selected)
		_action_selected(action_picker.selected)
		action_picker.grab_focus()
		if not state.history.is_empty():
			var last: Dictionary = state.history.back()
			_label(content, "Último sol · %s: energía %+d, oxígeno %+d, comida %+d, ciencia %+d." % [session.rules.config.actions[last.action].label, last.energy, last.oxygen, last.food, last.science], 18, MUTED)
	_button(content, "Mostrar / ocultar bitácora completa", func(): log_text.visible = not log_text.visible)
	log_text = _label(content, _history(), 18, MUTED)
	log_text.visible = state.phase == MissionState.Phase.FINISHED
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 12)
	content.add_child(navigation)
	_button(navigation, "Fuentes", _show_sources)
	_button(navigation, "Menú", _show_menu)

func _action_selected(index: int) -> void:
	selected_action = str(action_picker.get_item_metadata(index))
	var check := session.rules.preview(session.state, selected_action)
	action_detail.text = session.rules.config.actions[selected_action].description
	action_preview.text = _preview_text(check)
	execute_button.disabled = not check.ok

func _history() -> String:
	if session.state.history.is_empty():
		return "Aquí verás las consecuencias de tus decisiones. Tú eliges el plan."
	var lines := PackedStringArray()
	for entry in session.state.history:
		lines.append("Sol %d · %s · %s: energía %+d, oxígeno %+d, comida %+d, hallazgos %+d" % [entry.sol, session.rules.config.events[entry.event].label, session.rules.config.actions[entry.action].label, entry.energy, entry.oxygen, entry.food, entry.science])
		var budget: Dictionary = entry.budget
		lines.append("  Energía: −%d trabajo +%d solar almacenada (%d sin espacio). Oxígeno: +%d producido −%d consumo." % [budget.cost, budget.solar_stored, budget.solar_spilled, budget.oxygen_produced, budget.oxygen_consumed])
		lines.append("  Alimentos: +%d cosecha −%d consumo. %s" % [budget.crop.harvest, budget.food_consumed, _crop_text(budget.crop)])
		if budget.radio_due_sol > 0:
			lines.append("  Consulta enviada: respuesta al inicio del sol %d (consejo, no suministros)." % budget.radio_due_sol)
		if budget.uses_advice:
			lines.append("  Consejo aplicado: mejoró esta producción local de oxígeno.")
	return "\n".join(lines)

func _preview_text(preview: Dictionary) -> String:
	if not preview.ok:
		return "No disponible: " + str(preview.reason)
	var text := "Energía: aire %d + ciencia %d + cultivo %d + trabajo/radio %d = %d.\nProduce %d de oxígeno y %d hallazgos.\nAl cerrar el sol: energía %d · oxígeno %d · comida %d." % [preview.allocation.life_support, preview.allocation.science, preview.allocation.greenhouse, preview.work_energy, preview.cost, preview.oxygen_produced, preview.science_gained, preview.energy_after, preview.oxygen_after, preview.food_after]
	text += "\n" + _crop_text(preview.crop)
	if preview.materials_used > 0:
		text += "\nMateriales locales: −%d." % preview.materials_used
	if preview.radio_due_sol > 0:
		text += "\nConsejo pendiente hasta el inicio del sol %d; no llegan suministros." % preview.radio_due_sol
		if preview.radio_due_sol > int(session.rules.config.mission_sols):
			text += " No llegará antes de terminar la misión."
	if preview.oxygen_consumed > int(session.rules.config.oxygen_per_sol):
		text += "\nIncluye oxígeno extra del equipo: consumo total %d este sol." % preview.oxygen_consumed
	if preview.uses_advice:
		text += "\nIncluye el consejo recibido; se usa una sola vez."
	if preview.safety_stop:
		text += "\n¡ALERTA! Sin protección suficiente: este plan detiene la misión por seguridad."
	if preview.solar_spilled > 0:
		text += "\nBatería llena: %d de energía solar no se almacenan." % preview.solar_spilled
	if preview.oxygen_after == 0 or preview.food_after == 0:
		text += "\n¡Atención! Este plan agota una reserva y termina la misión."
	return text

func _crop_text(crop: Dictionary) -> String:
	if crop.interrupted:
		return "Cultivo interrumpido: pierdes el progreso y la energía invertida no se devuelve."
	if crop.harvest > 0:
		return "Cosecha este sol: +%d alimentos antes del consumo." % crop.harvest
	if crop.remaining > 0:
		return "Cosecha prevista al cerrar sol %d si cuidas %d sol(es) más sin interrupción." % [crop.due_sol, crop.remaining]
	return "Sin cosecha pendiente."

func _show_sources() -> void:
	_page()
	_label(content, "Ciencia que inspira la misión", 36)
	_label(content, "Los números y tiempos del juego son inventados para aprender a planificar.\nNo representan dosis de radiación ni una base real. NASA no avala este juego.", 23)
	if not science_provider.error.is_empty():
		_label(content, science_provider.error, 20)
	for record in science_catalog.get("records", []):
		_label(content, record.title + " · HISTÓRICO", 24, ACCENT)
		_label(content, record.observation + "\n" + record.context + "\n" + record.lesson + "\nLímite: " + record.limits, 19)
		_button(content, "Abrir registro " + record.id + " ↗", func(): OS.shell_open(record.url))
	for item in [["DONKI · Eventos solares", "https://ccmc.gsfc.nasa.gov/tools/DONKI/"], ["OSDR · Estudios de biología espacial", "https://osdr.nasa.gov/bio/repo/search?q=&data_source=cgene,alsda,esa&data_type=study"], ["RadLab · Mediciones contextualizadas", "https://visualization.osdr.nasa.gov/radlab/gui/data-api/"]]:
		_button(content, item[0] + " ↗", func(): OS.shell_open(item[1]))
	_label(content, "Tres fuentes históricas archivadas. Lecturas y explicaciones disponibles sin conexión.\nCreado con Godot Engine (licencia MIT). Interfaz y gráficos originales del proyecto.", 19, MUTED)
	_button(content, "Volver", _show_mission if session.state != null else _show_menu).grab_focus()

func _label(parent: Node, text: String, font_size: int, color: Color = PAPER) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 54
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	parent.add_child(button)
	return button
