extends Node

# --- Grid ---
const CELL_SIZE := 80
const GRID_COLS := 64
const GRID_ROWS := 64
const GRID_OFFSET := Vector2(0, 0)

# --- Enums ---
enum Direction { RIGHT, DOWN, LEFT, UP }
enum ComponentType { NONE, CONVEYOR, SOURCE, OPERATOR, TARGET, SPLITTER }
enum OperatorType { ADD, SUBTRACT, MULTIPLY, DIVIDE }
enum ToolMode { NONE, CONVEYOR, OPERATOR_ADD, OPERATOR_SUB, OPERATOR_MUL, OPERATOR_DIV, SPLITTER, DELETE }

# --- Direction vectors ---
const DIR_VECTORS := {
	Direction.RIGHT: Vector2i(1, 0),
	Direction.DOWN: Vector2i(0, 1),
	Direction.LEFT: Vector2i(-1, 0),
	Direction.UP: Vector2i(0, -1),
}

const DIR_ANGLES := {
	Direction.RIGHT: 0.0,
	Direction.DOWN: PI / 2.0,
	Direction.LEFT: PI,
	Direction.UP: -PI / 2.0,
}

# --- Colors ---
const COLOR_BG := Color(0.12, 0.12, 0.15)
const COLOR_GRID_BG := Color(0.16, 0.16, 0.19)
const COLOR_GRID_LINE := Color(0.22, 0.22, 0.26)
const COLOR_CONVEYOR := Color(0.38, 0.40, 0.45)
const COLOR_CONVEYOR_ARROW := Color(0.55, 0.58, 0.65)
const COLOR_SOURCE := Color(0.25, 0.72, 0.38)
const COLOR_SOURCE_DARK := Color(0.18, 0.55, 0.28)
const COLOR_OPERATOR := Color(0.35, 0.45, 0.85)
const COLOR_OPERATOR_DARK := Color(0.25, 0.32, 0.65)
const COLOR_TARGET := Color(0.92, 0.62, 0.15)
const COLOR_TARGET_DARK := Color(0.72, 0.45, 0.10)
const COLOR_TARGET_OK := Color(0.3, 0.85, 0.4)
const COLOR_SPLITTER := Color(0.7, 0.45, 0.75)
const COLOR_SPLITTER_DARK := Color(0.5, 0.3, 0.55)
const COLOR_BALL := Color(1.0, 1.0, 1.0)
const COLOR_BALL_TEXT := Color(0.1, 0.1, 0.15)
const COLOR_TOOLBAR_BG := Color(0.13, 0.13, 0.16)
const COLOR_TOOLBAR_BTN := Color(0.22, 0.22, 0.28)
const COLOR_TOOLBAR_BTN_SEL := Color(0.4, 0.5, 0.9)
const COLOR_HOVER := Color(1.0, 1.0, 1.0, 0.15)
const COLOR_INVALID := Color(1.0, 0.3, 0.3, 0.3)

# --- Operator symbols ---
const OP_SYMBOLS := {
	OperatorType.ADD: "+",
	OperatorType.SUBTRACT: "−",
	OperatorType.MULTIPLY: "×",
	OperatorType.DIVIDE: "÷",
}

# --- Speed ---
const BALL_MOVE_DURATION := 0.45  # seconds per cell
const SOURCE_EMIT_INTERVAL := 2.5  # seconds between emissions

# --- Utility functions ---
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return GRID_OFFSET + Vector2(grid_pos) * CELL_SIZE + Vector2(CELL_SIZE, CELL_SIZE) / 2.0

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var local := world_pos - GRID_OFFSET
	return Vector2i(int(floor(local.x / CELL_SIZE)), int(floor(local.y / CELL_SIZE)))

func is_valid_cell(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GRID_COLS and grid_pos.y >= 0 and grid_pos.y < GRID_ROWS

func opposite_dir(dir: Direction) -> Direction:
	return (dir + 2) % 4 as Direction

func next_direction(dir: Direction) -> Direction:
	return (dir + 1) % 4 as Direction

func format_number(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return "%.1f" % value
