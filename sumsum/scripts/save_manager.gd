extends Node

## Manages save/load of player progress to user://save_data.json

const SAVE_PATH := "user://save_data.json"
const SAVE_VERSION := 1

# In-memory state
var _data: Dictionary = {}

func _ready() -> void:
	load_progress()

# --- Public API ---

func mark_level_complete(pack_idx: int, level_idx: int) -> void:
	var key := "pack_%d" % pack_idx
	if not _data.completed.has(key):
		_data.completed[key] = []
	if level_idx not in _data.completed[key]:
		_data.completed[key].append(level_idx)
	save_progress()

func is_level_complete(pack_idx: int, level_idx: int) -> bool:
	var key := "pack_%d" % pack_idx
	if not _data.completed.has(key):
		return false
	return level_idx in _data.completed[key]

func get_completed_count(pack_idx: int) -> int:
	var key := "pack_%d" % pack_idx
	if not _data.completed.has(key):
		return 0
	return _data.completed[key].size()

func reset_all() -> void:
	_data = _default_data()
	save_progress()

# --- Persistence ---

func save_progress() -> void:
	var json_str := JSON.stringify(_data, "\t")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_str)

func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_data = _default_data()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		_data = _default_data()
		return
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	if err != OK:
		_data = _default_data()
		return
	_data = json.data
	if not _data.has("version") or not _data.has("completed"):
		_data = _default_data()

func _default_data() -> Dictionary:
	return {"version": SAVE_VERSION, "completed": {}}
