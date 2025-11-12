extends Control

# ----------------- Layout -----------------
@export var rect_size: Vector2 = Vector2(56, 64)
@export var rect_spacing: int = 8
@export var top_left: Vector2 = Vector2(24, 40)

# ----------------- Colors -----------------
@export var outline_color: Color = Color(0, 0, 0, 1)
@export var text_color: Color = Color(0, 0, 0, 1)
@export var current_day_tint: Color = Color(0, 0, 0, 0.55)

# ----------------- Seasons -----------------
const SEASONS: Array[String] = ["Summer", "Fall", "Winter", "Spring"]
var SEASON_COLORS: Dictionary = {
	"Summer": Color(0.90, 0.98, 0.80),  # light green
	"Fall":   Color(0.98, 0.90, 0.78),  # light orange
	"Winter": Color(0.85, 0.90, 0.98),  # light blue
	"Spring": Color(0.92, 0.98, 0.90)   # mint
}

# ----------------- Fonts -----------------
var default_font: Font = null
var default_font_size: int = 14
var small_font_size: int = 12

# Redraw caching
var _last_seen_block_start: int = -1
var _last_seen_day: int = -1

func _ready() -> void:
	default_font = get_theme_default_font()
	default_font_size = get_theme_default_font_size()
	small_font_size = max(10, int(default_font_size * 0.85))
	set_process(true)
	queue_redraw()

func _process(_delta: float) -> void:
	var stats: Node = _get_stats()
	if stats == null:
		return

	var today: int = _normalize_day(int(stats.day_number))
	var block_start: int = _season_block_start(today)

	if today != _last_seen_day or block_start != _last_seen_block_start:
		_last_seen_day = today
		_last_seen_block_start = block_start
		
		#YOU CAN READ var stats = get_node("/root/GlobalStats") for current season
		var season_index := _season_index_for_day(today)
		var season_name := SEASONS[season_index]
		var stats_node := _get_stats()
		if stats_node != null:
			stats_node.current_season = season_name

		queue_redraw()

func _get_stats() -> Node:
	if has_node("/root/GlobalStats"):
		return get_node("/root/GlobalStats")
	return null

# Ensure no day 0 in UI
func _normalize_day(raw_day: int) -> int:
	return max(1, raw_day)

# Index 0..3 across seasons based on absolute day
func _season_index_for_day(day_num: int) -> int:
	var idx: int = int(floor(float(day_num - 1) / 7.0)) % SEASONS.size()
	if idx < 0:
		idx = 0
	return idx

# Absolute day of the first day of this season block (1, 8, 15, 22, ...)
func _season_block_start(day_num: int) -> int:
	var idx: int = _season_index_for_day(day_num)
	return idx * 7 + 1

# 1..7 within the season block
func _day_in_block(day_abs: int) -> int:
	return ((day_abs - 1) % 7) + 1

func _draw() -> void:
	var stats: Node = _get_stats()
	var today_abs: int = 1
	if stats != null:
		today_abs = _normalize_day(int(stats.day_number))

	var block_start: int = _season_block_start(today_abs)
	var days: Array[int] = []
	days.resize(7)
	for i in range(7):
		days[i] = block_start + i

	# Draw the seven cells
	for i in range(7):
		var day_abs: int = days[i]
		var season_idx: int = _season_index_for_day(day_abs)
		var season_name: String = SEASONS[season_idx]
		var day_in_block: int = _day_in_block(day_abs)

		var cell_pos: Vector2 = Vector2(
			top_left.x + float(i) * (rect_size.x + float(rect_spacing)),
			top_left.y
		)
		var cell_rect: Rect2 = Rect2(cell_pos, rect_size)

		# Season fill
		var fill: Color = SEASON_COLORS.get(season_name, Color(1, 1, 1))
		draw_rect(cell_rect, fill)

		# Outline
		draw_rect(cell_rect, outline_color, false, 2.0)

		# Centered day number
		if default_font != null:
			var day_text: String = str(day_in_block)
			var size_vec: Vector2 = default_font.get_string_size(day_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, default_font_size)
			var text_width: float = size_vec.x
			var center_x: float = cell_pos.x + (rect_size.x - text_width) * 0.5
			var baseline_y: float = cell_pos.y + rect_size.y * 0.58
			draw_string(default_font, Vector2(center_x, baseline_y), day_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, default_font_size, text_color)

		# Shade today's cell
		var is_today_index: int = today_abs - block_start  # 0..6 within the block
		if i == is_today_index:
			draw_rect(cell_rect, current_day_tint)

	# Season label centered under the whole 7-day block
	if default_font != null:
		var label_y: float = top_left.y + rect_size.y + 18.0
		var block_season_name: String = SEASONS[_season_index_for_day(block_start)]
		var sw_vec: Vector2 = default_font.get_string_size(block_season_name, HORIZONTAL_ALIGNMENT_LEFT, -1.0, small_font_size)
		var sw: float = sw_vec.x

		var block_left: float = top_left.x
		var block_right: float = top_left.x + 6.0 * (rect_size.x + float(rect_spacing)) + rect_size.x
		var block_center: float = (block_left + block_right) * 0.5
		draw_string(default_font, Vector2(block_center - sw * 0.5, label_y), block_season_name, HORIZONTAL_ALIGNMENT_LEFT, -1.0, small_font_size, text_color)

func refresh() -> void:
	queue_redraw()
