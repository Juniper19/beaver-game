extends Control

@export var calendar_spritesheet: Texture2D
@export var top_left: Vector2 = Vector2(24, 10)
@export var spacing: float = 8.0

var tile_w: float
var tile_h: float

var calendar_day = 1


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

	var control_w = size.x
	var calendar_w = (tile_w * 7.0) + (spacing * 6.0)
	var top_left_x = (control_w - calendar_w) * 0.5
	var top_left_y = top_left.y

	var today = max(stats.calendar_day, 0)
	var block_start = _season_block_start(max(today,1))
	var season_row = _season_index_for_day(max(today,1))

	for i in range(7):
		var day_abs = block_start + i
		var day_index = _day_in_block(day_abs) - 1  # 0..6

		# Past OR today, X tile
		var is_past_or_today = day_abs <= today
		var tile_index = 7 if is_past_or_today else day_index

		var src = Rect2(
			Vector2(tile_index * tile_w, season_row * tile_h),
			Vector2(tile_w, tile_h)
		)
		
		if (tile_index == 7):
			src = Rect2(
				Vector2(tile_index * tile_w, season_row * tile_h),
				Vector2(tile_w, tile_h)
			)

		var dst_pos = Vector2(
			top_left_x + i * (tile_w + spacing),
			top_left_y
		)

		draw_texture_rect_region(
			calendar_spritesheet,
			Rect2(dst_pos, Vector2(tile_w, tile_h)),
			src
		)
