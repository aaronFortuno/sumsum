class_name PackAddition

static func get_pack() -> Dictionary:
	return {
		"id": "addition",
		"title": "Sumar",
		"description": "Domina la suma col·locant operadors i cintes.",
		"difficulty": Packs.Difficulty.EASY,
		"target_age": [10, 12],
		"color": Color(0.3, 0.7, 0.9),
		"levels": _get_levels(),
	}

static func _get_levels() -> Array[Dictionary]:
	return [
		# --- 1. Suma simple ---
		{
			"title": "Suma simple",
			"description": "Col·loca un sumador (+) i connecta les fonts.\n3 + 5 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 5, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 8},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"hint": "Col·loca el + entre les dues fonts i apunta'l cap a la dreta.",
		},
		# --- 2. Suma amb tres nombres ---
		{
			"title": "Suma amb tres nombres",
			"description": "Un operador pot rebre més de dues entrades.\n2 + 3 + 4 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 4, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 9},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"hint": "Porta els tres nombres al mateix sumador.",
		},
		# --- 3. Dos destins ---
		{
			"title": "Dos destins",
			"description": "Dos destins, dues sumes!\nUtilitza les fonts per alimentar dos sumadors.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 6, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 7},
				{"pos": Vector2i(11, 5), "value": 9},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"hint": "Cada destí necessita el seu propi sumador.",
		},
		# --- 4. Suma en cadena ---
		{
			"title": "Suma en cadena",
			"description": "Encadena dos sumadors!\nEl resultat d'un pot entrar a un altre.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(6, 0), "value": 4, "dir": Constants.Direction.DOWN},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 9},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"hint": "Suma primer 2+3, després suma-hi el 4.",
		},
		# --- 5. El gran sumador ---
		{
			"title": "El gran sumador",
			"description": "Nombres més grans!\n15 + 27 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 15, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 27, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 42},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"hint": "És una suma directa. On col·loques el +?",
		},
		# --- 6. Quina sobra? ---
		{
			"title": "Quina sobra?",
			"description": "No totes les fonts són necessàries!\nAconsegueix 10.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 8, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 10},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"hint": "Quines dues fonts sumen 10?",
		},
		# --- 7. Suma limitada ---
		{
			"title": "Suma limitada",
			"description": "Només tens 2 sumadors!\n3 + 4 + 5 + 6 = 18",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 6, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 18},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"tool_limits": {Constants.ToolMode.OPERATOR_ADD: 2},
			"hint": "Agrupa les fonts en dues parelles i encadena els resultats.",
		},
		# --- 8. Tres camins ---
		{
			"title": "Tres camins",
			"description": "Una font pot servir per a diversos destins!\nObjectius: 5, 6 i 9.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 5, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 5},
				{"pos": Vector2i(11, 3), "value": 6},
				{"pos": Vector2i(11, 5), "value": 9},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"hint": "El 5 va directe. 1+5=6. 4+5=9.",
		},
		# --- 9. Sense drecera ---
		{
			"title": "Sense drecera",
			"description": "2 sumadors per a 4 nombres.\n7 + 8 + 2 + 3 = 20",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 7, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 8, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 3, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 20},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"tool_limits": {Constants.ToolMode.OPERATOR_ADD: 2},
			"hint": "(7+3)+(8+2) = 10+10 = 20.",
		},
		# --- 10. El laberint de sumes ---
		{
			"title": "El laberint de sumes",
			"description": "6 fonts, moltes combinacions!\nAconsegueix 12.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 1), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 6, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 12},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"hint": "3+4+5=12, o 6+5+1=12, o 2+4+6=12...",
		},
	]
