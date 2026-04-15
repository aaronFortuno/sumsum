class_name PackSubtraction

static func get_pack() -> Dictionary:
	return {
		"id": "subtraction",
		"title": "Restar",
		"description": "Aprèn la resta i la importància de l'ordre.",
		"difficulty": Packs.Difficulty.EASY,
		"target_age": [10, 12],
		"color": Color(0.9, 0.5, 0.3),
		"levels": _get_levels(),
	}

static func _get_levels() -> Array[Dictionary]:
	return [
		# --- 1. Resta bàsica ---
		{
			"title": "Resta bàsica",
			"description": "El restador fa A−B. Porta el 10 a l'entrada A\ni el 4 a l'entrada B.\n10 − 4 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 10, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 4, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 6},
			],
			"fixed_operators": [
				{"pos": Vector2i(5, 3), "op": Constants.OperatorType.SUBTRACT, "dir": Constants.Direction.RIGHT},
			],
			"fixed_conveyors": [],
			"available_tools": [Constants.ToolMode.CONVEYOR],
			"hint": "Porta el 10 a l'entrada marcada A i el 4 a la B.",
		},
		# --- 2. Qui va primer? ---
		{
			"title": "Qui va primer?",
			"description": "Ara col·loca tu el restador.\nFixa't en les lletres A i B per saber on va cada nombre.\n8 − 3 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 8, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 3, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 5},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_SUB,
			],
			"hint": "El 8 va a l'entrada A i el 3 a la B.",
		},
		# --- 3. Resultat negatiu? ---
		{
			"title": "Resultat negatiu?",
			"description": "Les restes poden donar nombres negatius!\n3 − 7 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 7, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": -4},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_SUB,
			],
			"hint": "El 3 va a l'entrada A del restador.",
		},
		# --- 4. Suma i resta ---
		{
			"title": "Suma i resta",
			"description": "Combina suma i resta.\n(8 + 5) − 3 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 8, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 3, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 10},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_SUB,
			],
			"hint": "Primer suma 8+5=13, després resta 13−3=10.",
		},
		# --- 5. Diferències ---
		{
			"title": "Diferències",
			"description": "La mateixa parella, resultats diferents!\n12 + 5 = ? i 12 − 5 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 12, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 5, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 17},
				{"pos": Vector2i(11, 5), "value": 7},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_SUB,
			],
			"hint": "Necessites dos operadors: un + per al 17, i un − per al 7.",
		},
		# --- 6. Operació correcta ---
		{
			"title": "Operació correcta",
			"description": "Tens totes les operacions, però només una dóna 8.\n12 ? 4 = 8",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 12, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 4, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 8},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_SUB,
				Constants.ToolMode.OPERATOR_MUL,
				Constants.ToolMode.OPERATOR_DIV,
			],
			"hint": "12 − 4 = 8.",
		},
		# --- 7. Doble resta ---
		{
			"title": "Doble resta",
			"description": "Encadena dues restes!\n20 − 5 − 3 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 20, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 3, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 12},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_SUB,
			],
			"tool_limits": {Constants.ToolMode.OPERATOR_SUB: 2},
			"hint": "20−5=15, 15−3=12.",
		},
		# --- 8. Qui sobra? ---
		{
			"title": "Qui sobra?",
			"description": "No totes les fonts són necessàries!\nAconsegueix 7.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 15, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 8, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 4, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 7},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_SUB,
			],
			"hint": "15 − 8 = 7. Les fonts 3 i 4 no calen!",
		},
		# --- 9. Suma o resta? ---
		{
			"title": "Suma o resta?",
			"description": "Dos objectius, operacions diferents!\n10, 7, 3 → 6 i 20",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 10, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 7, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 3, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 6},
				{"pos": Vector2i(11, 5), "value": 20},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_SUB,
			],
			"hint": "10−7+3=6 i 10+7+3=20.",
		},
		# --- 10. Equilibri ---
		{
			"title": "Equilibri",
			"description": "Dos resultats d'un conjunt de fonts.\nObjectius: 10 i 7.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 18, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 10, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 3, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 10},
				{"pos": Vector2i(11, 5), "value": 7},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_SUB,
			],
			"hint": "18−5−3=10 i 10−3=7.",
		},
	]
