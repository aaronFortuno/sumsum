class_name Packs

enum Difficulty { TUTORIAL, EASY, MEDIUM, HARD, EXPERT }

static func get_all_packs() -> Array[Dictionary]:
	return [
		PackTutorial.get_pack(),
		PackAddition.get_pack(),
		PackSubtraction.get_pack(),
		PackMultiplication.get_pack(),
		PackDivision.get_pack(),
		PackCombined.get_pack(),
		PackChallenge.get_pack(),
		PackExpert.get_pack(),
	]

static func get_pack(index: int) -> Dictionary:
	return get_all_packs()[index]

static func get_pack_count() -> int:
	return get_all_packs().size()

static func get_all_levels_flat() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for pack in get_all_packs():
		for level in pack.get("levels", []):
			result.append(level)
	return result
