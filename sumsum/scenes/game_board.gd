extends Node2D

## Orchestrator: holds shared state, lifecycle hooks, and delegates to modules.
##
## Modules (RefCounted helpers in scripts/board/):
##   drawing   — grid/overlay drawing, toolbar visuals
##   input     — mouse/keyboard, drag state for conveyors and deletion
##   placement — place/delete conveyors and operators, tool counting
##   routing   — ball spawning, routing, queue system
##   levels    — level setup, win condition, level selector overlay

# ==========================================================================
# Shared state (accessed by modules via this object)
# ==========================================================================

var grid_mgr := GridManager.new()
var number_balls: Array[NumberBall] = []
var sources: Array[NumberSource] = []
var operators: Array[OperatorBlock] = []
var targets: Array[TargetBlock] = []

# Interaction state
var current_tool: int = Constants.ToolMode.CONVEYOR
var current_direction: int = Constants.Direction.RIGHT
var hover_cell: Vector2i = Vector2i(-1, -1)
var level_complete := false

# Stopped balls waiting at conveyor exit edges
var occupied_cells: Dictionary = {}  # Vector2i → NumberBall

# Level state
var current_pack: int = 0
var current_level: int = 0
var level_data: Dictionary = {}
var all_packs: Array[Dictionary] = []
var tool_counts: Dictionary = {}  # ToolMode → int (placed count)
var active_grid_size: Vector2i = Vector2i(12, 7)

# Camera and UI layer
var camera: Camera2D
var ui_layer: CanvasLayer

# Preloaded scenes
var ball_scene := preload("res://scenes/components/number_ball.tscn")

# ==========================================================================
# Modules
# ==========================================================================

var drawing: BoardDrawing
var input: BoardInput
var placement: BoardPlacement
var routing: BoardRouting
var levels: BoardLevels

# ==========================================================================
# Lifecycle
# ==========================================================================

func _ready() -> void:
	# Camera for zoom/pan
	camera = Camera2D.new()
	camera.name = "Camera"
	add_child(camera)
	camera.make_current()

	# UI layer: toolbar and labels stay fixed on screen
	ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	ui_layer.layer = 10
	add_child(ui_layer)

	# Instantiate modules (order matters: drawing before input/levels which reference it)
	drawing = BoardDrawing.new(self)
	routing = BoardRouting.new(self)
	placement = BoardPlacement.new(self)
	input = BoardInput.new(self)
	levels = BoardLevels.new(self)

	all_packs = Packs.get_all_packs()
	levels.show_level_selector()

func _process(delta: float) -> void:
	input.process_pan(delta)

func _input(event: InputEvent) -> void:
	input.handle_input(event)

func _draw() -> void:
	drawing.draw_world()

# ==========================================================================
# Coordinate helpers
# ==========================================================================

func screen_to_world(screen_pos: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * screen_pos

func center_camera_on_level() -> void:
	var grid_pixel_size := Vector2(active_grid_size) * Constants.CELL_SIZE
	var center: Vector2 = Constants.GRID_OFFSET + grid_pixel_size / 2.0
	camera.position = center
	# Auto-zoom to fit the grid (1280x620 visible area, toolbar=100px)
	var visible_w := 1280.0
	var visible_h := 620.0
	var zoom_x: float = visible_w / grid_pixel_size.x
	var zoom_y: float = visible_h / grid_pixel_size.y
	var fit_zoom: float = minf(zoom_x, zoom_y) * 0.9
	camera.zoom = Vector2(fit_zoom, fit_zoom).clamp(BoardInput.ZOOM_MIN, BoardInput.ZOOM_MAX)

# ==========================================================================
# Public API (called by modules and external code)
# ==========================================================================

func load_pack_level(pack_idx: int, level_idx: int) -> void:
	current_pack = pack_idx
	current_level = level_idx
	if pack_idx >= all_packs.size():
		return
	var pack: Dictionary = all_packs[pack_idx]
	var pack_levels: Array = pack.get("levels", [])
	if level_idx >= pack_levels.size():
		return
	level_data = pack_levels[level_idx]
	active_grid_size = level_data.get("grid_size", Vector2i(12, 7))
	levels.clear_board()
	levels.setup_level()
	levels.setup_toolbar()
	levels.setup_level_info()
	current_tool = Constants.ToolMode.CONVEYOR
	center_camera_on_level()
	for source in sources:
		source.start()
	queue_redraw()
	drawing.redraw_toolbar()

func check_win() -> void:
	levels.check_win()
