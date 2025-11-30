extends Control

@export var calendar_spritesheet: Texture2D
@export var top_left: Vector2 = Vector2(24, 40)
@export var spacing: float = 8.0

var tile_w: float
var tile_h: float


func _ready() -> void:
	tile_w = calendar_spritesheet.get_width() / 8.0
	tile_h = calendar_spritesheet.get_height() / 4.0
	set_process(true)


func _process(_delta: float) -> void:
	queue_redraw()


func _get_stats() -> Node:
	if has_node("/root/GlobalStats"):
		return get_node("/root/GlobalStats")
	return null


func _season_index_for_day(day: int) -> int:
	return int(floor(float(day - 1) / 7.0)) % 4


func _season_block_start(day: int) -> int:
	return _season_index_for_day(day) * 7 + 1


func _day_in_block(day: int) -> int:
	return ((day - 1) % 7) + 1

func _draw() -> void:
	var stats = _get_stats()
	if not stats:
		return

	var today = max(stats.day_number, 1)
	var block_start = _season_block_start(today)
	var season_row = _season_index_for_day(today)  # 0 = Spring, 1 = Summer, etc.

	for i in range(7):
		var day_abs = block_start + i
		var day_index = _day_in_block(day_abs) - 1   # 0-6

		# Past OR today, use X tile
		var is_past_or_today = day_abs <= today
		var tile_index = 7 if is_past_or_today else day_index

		var src = Rect2(
			Vector2(tile_index * tile_w, season_row * tile_h),
			Vector2(tile_w, tile_h)
		)

		var dst_pos = Vector2(
			top_left.x + i * (tile_w + spacing),
			top_left.y
		)

		draw_texture_rect_region(
			calendar_spritesheet,
			Rect2(dst_pos, Vector2(tile_w, tile_h)),
			src
		)
