extends Control

const INK := Color("101c2c")
const PAPER := Color("eaf1f7")
const MUTED := Color("a8bdce")
const ACCENT := Color("74e0c2")

var session: MissionSession
var content: VBoxContainer
var status: Label
var actions: GridContainer
var log_text: Label
var seed_input: SpinBox

func _ready() -> void:
	_setup_theme()
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
	content.add_theme_constant_override("separation", 16)
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
	var start_button := _button(content, "Comenzar misión  →", func(): session.start(int(seed_input.value)))
	start_button.grab_focus()
	_button(content, "Fuentes y créditos", _show_sources)
	_label(content, "Simulación educativa • Sin cuentas • Sin conexión durante la partida", 17, MUTED)

func _show_mission() -> void:
	_page()
	var state := session.state
	_label(content, "SOL %d / 7   ·   BASE AURORA" % state.sol, 34)
	_label(content, "ENERGÍA  %d / %d     |     OXÍGENO  %d     |     ALIMENTOS  %d" % [state.energy, session.rules.config.battery_capacity, state.oxygen, state.food], 26, ACCENT)
	_label(content, "Hallazgos: %d  ·  Unidades de juego, no medidas reales" % state.science, 17, MUTED)
	_label(content, "INVERNADERO · %d / %d soles de cuidado. Cosecha: +%d alimentos.\nTiempo comprimido para jugar: las plantas reales no crecen en dos días. Una tarea distinta pierde el progreso del ciclo." % [state.crop_progress, session.rules.config.crop_turns, session.rules.config.harvest_food], 18, MUTED)
	status = _label(content, "Elige un plan de energía para este sol. Después del trabajo: oxígeno −%d, alimentos −%d y producción solar +%d (hasta llenar la batería)." % [session.rules.config.oxygen_per_sol, session.rules.config.food_per_sol, session.rules.config.solar_per_sol], 20)
	if state.phase == MissionState.Phase.FINISHED:
		_label(content, state.outcome, 28)
		_button(content, "Volver a planear", _show_menu).grab_focus()
	else:
		actions = GridContainer.new()
		actions.columns = 2
		actions.add_theme_constant_override("h_separation", 14)
		actions.add_theme_constant_override("v_separation", 12)
		content.add_child(actions)
		for action_id in session.rules.config.actions:
			var action: Dictionary = session.rules.config.actions[action_id]
			var check := session.rules.preview(state, action_id)
			var card := VBoxContainer.new()
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			actions.add_child(card)
			var button := _button(card, action.label, session.choose.bind(action_id, state.sol))
			button.disabled = not check.ok
			_label(card, action.description, 18, MUTED)
			_label(card, _preview_text(check), 18, ACCENT if check.ok else Color("ffca88"))
			if check.ok and not get_viewport().gui_get_focus_owner():
				button.grab_focus()
	_label(content, "BITÁCORA · Qué cambió y por qué", 20, ACCENT)
	log_text = _label(content, _history(), 18, MUTED)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 12)
	content.add_child(navigation)
	_button(navigation, "Fuentes", _show_sources)
	_button(navigation, "Menú", _show_menu)

func _history() -> String:
	if session.state.history.is_empty():
		return "Aquí verás las consecuencias de tus decisiones. Tú eliges el plan."
	var lines := PackedStringArray()
	for entry in session.state.history:
		lines.append("Sol %d · %s: energía %+d, oxígeno %+d, comida %+d, hallazgos %+d" % [entry.sol, session.rules.config.actions[entry.action].label, entry.energy, entry.oxygen, entry.food, entry.science])
		var budget: Dictionary = entry.budget
		lines.append("  Energía: −%d trabajo +%d solar almacenada (%d sin espacio). Oxígeno: +%d producido −%d consumo." % [budget.cost, budget.solar_stored, budget.solar_spilled, budget.oxygen_produced, budget.oxygen_consumed])
		lines.append("  Alimentos: +%d cosecha −%d consumo. %s" % [budget.crop.harvest, budget.food_consumed, _crop_text(budget.crop)])
	return "\n".join(lines)

func _preview_text(preview: Dictionary) -> String:
	if not preview.ok:
		return "No disponible: " + str(preview.reason)
	var text := "Asignación: aire %d + ciencia %d + cultivo %d = %d de energía.\nProduce %d de oxígeno y %d hallazgos.\nAl cerrar el sol: energía %d · oxígeno %d · comida %d." % [preview.allocation.life_support, preview.allocation.science, preview.allocation.greenhouse, preview.cost, preview.oxygen_produced, preview.science_gained, preview.energy_after, preview.oxygen_after, preview.food_after]
	text += "\n" + _crop_text(preview.crop)
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
	for item in [["DONKI · Eventos solares", "https://ccmc.gsfc.nasa.gov/tools/DONKI/"], ["OSDR · Estudios de biología espacial", "https://osdr.nasa.gov/bio/repo/search?q=&data_source=cgene,alsda,esa&data_type=study"], ["RadLab · Mediciones contextualizadas", "https://visualization.osdr.nasa.gov/radlab/gui/data-api/"]]:
		_button(content, item[0] + " ↗", func(): OS.shell_open(item[1]))
	_label(content, "Registros concretos pendientes de incorporación.\nCreado con Godot Engine (licencia MIT). Interfaz y gráficos originales del proyecto.", 19, MUTED)
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
