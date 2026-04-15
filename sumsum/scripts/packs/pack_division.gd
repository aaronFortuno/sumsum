class_name PackDivision

static func get_pack() -> Dictionary:
	return {
		"id": "division",
		"title": "Dividir",
		"description": "Divisió exacta, operacions inverses i factors.",
		"difficulty": Packs.Difficulty.MEDIUM,
		"target_age": [11, 14],
		"color": Color(0.9, 0.7, 0.2),
		"levels": _get_levels(),
	}

static func _get_levels() -> Array[Dictionary]:
	return [
		# --- 1. Repartir ---
		{
			"title": "Repartir",
			"description": "El divisor fa A÷B. Porta el 20 a l'entrada A\ni el 4 a l'entrada B.\n20 ÷ 4 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 20, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 4, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 5},
			],
			"fixed_operators": [
				{"pos": Vector2i(5, 3), "op": Constants.OperatorType.DIVIDE, "dir": Constants.Direction.RIGHT},
			],
			"fixed_conveyors": [],
			"available_tools": [Constants.ToolMode.CONVEYOR],
			"hint": "Porta el 20 a l'entrada A i el 4 a la B.",
		},
		# --- 2. Divisió exacta ---
		{
			"title": "Divisió exacta",
			"description": "Divideix per obtenir un nombre enter.\n36 ÷ 6 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 36, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 6, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 6},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_DIV,
			],
			"hint": "El 36 va a l'entrada A i el 6 a la B.",
		},
		# --- 3. Multiplica i divideix ---
		{
			"title": "Multiplica i divideix",
			"description": "Combina multiplicació i divisió.\n(3 × 8) ÷ 4 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 8, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 4, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 6},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
				Constants.ToolMode.OPERATOR_DIV,
			],
			"hint": "Primer multiplica 3×8=24, després divideix 24÷4=6.",
		},
		# --- 4. Factors ---
		{
			"title": "Factors",
			"description": "El mateix nombre, divisors diferents.\n24 ÷ 3 = ? i 24 ÷ 4 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 3), "value": 24, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(5, 0), "value": 3, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(5, 6), "value": 4, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 8},
				{"pos": Vector2i(11, 5), "value": 6},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_DIV,
			],
			"hint": "Porta el 24 als dos divisors, cadascun amb el seu divisor.",
		},
		# --- 5. Quin divisor? ---
		{
			"title": "Quin divisor?",
			"description": "No totes les fonts són necessàries!\nAconsegueix 8.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 24, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 4, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 8},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_DIV,
			],
			"hint": "24 ÷ 3 = 8. La font 4 no cal!",
		},
		# --- 6. Divideix i suma ---
		{
			"title": "Divideix i suma",
			"description": "Combina divisió i suma!\n20 ÷ 4 + 3 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 20, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 3, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 8},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_DIV,
			],
			"hint": "20÷4=5, 5+3=8.",
		},
		# --- 7. Meitat i terç ---
		{
			"title": "Meitat i terç",
			"description": "La mateixa font, dos divisors!\n30÷2=? i 30÷3=?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 3), "value": 30, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(5, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(5, 6), "value": 3, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 15},
				{"pos": Vector2i(11, 5), "value": 10},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_DIV,
			],
			"hint": "30÷2=15, 30÷3=10.",
		},
		# --- 8. Divisió limitada ---
		{
			"title": "Divisió limitada",
			"description": "Dues divisions encadenades!\n60 ÷ 3 ÷ 5 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 60, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(6, 0), "value": 4, "dir": Constants.Direction.DOWN},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 4},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_DIV,
			],
			"tool_limits": {Constants.ToolMode.OPERATOR_DIV: 2},
			"hint": "60÷3=20, 20÷5=4. La font 4 no cal!",
		},
	]
