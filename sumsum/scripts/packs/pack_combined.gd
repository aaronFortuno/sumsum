class_name PackCombined

static func get_pack() -> Dictionary:
	return {
		"id": "combined",
		"title": "Operacions combinades",
		"description": "Totes quatre operacions. Tria la correcta!",
		"difficulty": Packs.Difficulty.HARD,
		"target_age": [12, 14],
		"color": Color(0.4, 0.8, 0.7),
		"levels": _get_levels(),
	}

static func _get_levels() -> Array[Dictionary]:
	return [
		# --- 1. Quatre operacions ---
		{
			"title": "Quatre operacions",
			"description": "Quina operació necessites?\n3 ? 5 = 15",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 5, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 15},
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
			"hint": "3 × 5 = 15",
		},
		# --- 2. Dues operacions diferents ---
		{
			"title": "Dues operacions diferents",
			"description": "Cada destí necessita una operació diferent.\n8 ? 2 = 10 i 8 ? 2 = 16",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 8, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 2, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 10},
				{"pos": Vector2i(11, 5), "value": 16},
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
			"hint": "8 + 2 = 10 per al primer, 8 × 2 = 16 per al segon.",
		},
		# --- 3. Expressió complexa ---
		{
			"title": "Expressió complexa",
			"description": "Tres operacions encadenades!\n(5 + 3) × 2 − 6 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 6, "dir": Constants.Direction.RIGHT},
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
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "5+3=8, 8×2=16, 16−6=10.",
		},
		# --- 4. Distribució ---
		{
			"title": "Distribució",
			"description": "Hi ha més d'una solució!\n3 × (4 + 2) = 3 × 4 + 3 × 2 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 2, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 18},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "Prova: primer 4+2=6, després 3×6=18.",
		},
		# --- 5. Tres destins ---
		{
			"title": "Tres destins",
			"description": "Tres operacions, tres resultats.\n12 ? 4 = 16, 48, 3",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 12, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 4, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 0), "value": 16},
				{"pos": Vector2i(11, 3), "value": 48},
				{"pos": Vector2i(11, 6), "value": 3},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
				Constants.ToolMode.OPERATOR_DIV,
			],
			"hint": "12+4=16, 12×4=48, 12÷4=3.",
		},
		# --- 6. Quin camí? ---
		{
			"title": "Quin camí?",
			"description": "Moltes fonts, molts camins possibles!\nAconsegueix 12.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 6, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 7, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 12},
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
			"hint": "3×4=12, o 5+7=12, o 6+3+... Tria!",
		},
		# --- 7. Recursos justos ---
		{
			"title": "Recursos justos",
			"description": "1 multiplicador i 1 sumador.\n8 × 2 + 3 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 8, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 3, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 19},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"tool_limits": {
				Constants.ToolMode.OPERATOR_ADD: 1,
				Constants.ToolMode.OPERATOR_MUL: 1,
			},
			"hint": "8×2=16, 16+3=19.",
		},
		# --- 8. Fàbrica doble ---
		{
			"title": "Fàbrica doble",
			"description": "Cada objectiu necessita una operació diferent!\nObjectius: 12 i 2.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 6, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 3, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 12},
				{"pos": Vector2i(11, 5), "value": 2},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
				Constants.ToolMode.OPERATOR_SUB,
			],
			"hint": "6×2=12 i 5−3=2.",
		},
		# --- 9. Tot sobra ---
		{
			"title": "Tot sobra",
			"description": "6 fonts! Quines necessites per a 21?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 10, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 1), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 7, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 2, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 21},
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
			"hint": "3×7=21, o 10+4+7=21, o 10+4+5+2=21...",
		},
		# --- 10. Cadena mixta ---
		{
			"title": "Cadena mixta",
			"description": "Només tens × i −.\n4 × 3 − 5 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 5, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 7},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_SUB,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "4×3=12, 12−5=7.",
		},
		# --- 11. Pont ---
		{
			"title": "Pont",
			"description": "Dos objectius, recursos justos!\nObjectius: 10 i 15.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 8, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 3, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 10},
				{"pos": Vector2i(11, 5), "value": 15},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"tool_limits": {
				Constants.ToolMode.OPERATOR_ADD: 1,
				Constants.ToolMode.OPERATOR_MUL: 1,
			},
			"hint": "8+2=10, 5×3=15.",
		},
		# --- 12. El gran puzzle ---
		{
			"title": "El gran puzzle",
			"description": "6 fonts, 2 objectius, recursos limitats!\nObjectius: 20 i 7.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 1), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 6, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 8, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 1, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 20},
				{"pos": Vector2i(11, 5), "value": 7},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_SUB,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"tool_limits": {
				Constants.ToolMode.OPERATOR_ADD: 1,
				Constants.ToolMode.OPERATOR_SUB: 1,
				Constants.ToolMode.OPERATOR_MUL: 1,
			},
			"hint": "4×5=20 i 8−1=7. Fonts 3 i 6 no calen!",
		},
	]
