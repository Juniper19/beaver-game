# u/kleonc on reddit
# https://www.reddit.com/r/godot/comments/mqp29g/comment/hddil1b/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

class_name SpawnArea

var polygon: PackedVector2Array
var triangles: PackedInt32Array
var rand: RandomNumberGenerator
var cumulative_areas: Array[float]

	
func _init(_polygon: PackedVector2Array):
	polygon = _polygon
	rand = RandomNumberGenerator.new()
	triangles = Geometry2D.triangulate_polygon(polygon)
	var poly: Polygon2D
	
	@warning_ignore("integer_division")
	var triangle_count: int = triangles.size() / 3
	
	#cumulative_areas.resize(triangle_count)
	#cumulative_areas[-1] = 0 # sneaky trick
	#for i in range(triangle_count):
		#var a: Vector2 = polygon[triangles[i * 3 + 0]]
		#var b: Vector2 = polygon[triangles[i * 3 + 1]]
		#var c: Vector2 = polygon[triangles[i * 3 + 2]]
		#
		#cumulative_areas[i] = cumulative_areas[i - 1] + triangle_area(a, b, c)
	
	cumulative_areas.resize(triangle_count)
	var sum: float = 0.0
	for i in range(triangle_count):
		var a: Vector2 = polygon[triangles[i*3]]
		var b: Vector2 = polygon[triangles[i*3 + 1]]
		var c: Vector2 = polygon[triangles[i*3 + 2]]

		sum += triangle_area(a, b, c)
		cumulative_areas[i] = sum


func n_points(n: int) -> Array[Vector2]:
	if n < 0:
		return []
	
	var points: Array[Vector2]
	
	#### CAN OPTIMIZE THIS 
	var total_area: float = cumulative_areas.back()
	for i in n:
		
		var chosen_area: int = int(total_area / float(n) * float(i))
		print(chosen_area)
		
		
		var chosen_triangle: int = cumulative_areas.bsearch(chosen_area)
		var a: Vector2 = polygon[triangles[3 * chosen_triangle + 0]]
		var b: Vector2 = polygon[triangles[3 * chosen_triangle + 1]]
		var c: Vector2 = polygon[triangles[3 * chosen_triangle + 2]]
		
		points.append(random_point_in_triangle(a, b, c))
	return points

func random_point() -> Vector2:
	var chosen_triangle: int = cumulative_areas.bsearch(rand.randf() * cumulative_areas.back())
	
	var a: Vector2 = polygon[triangles[3 * chosen_triangle + 0]]
	var b: Vector2 = polygon[triangles[3 * chosen_triangle + 1]]
	var c: Vector2 = polygon[triangles[3 * chosen_triangle + 2]]
	
	return random_point_in_triangle(a, b, c)
	

func triangle_area(a: Vector2, b: Vector2, c: Vector2) -> float:
	#print((b-a), " ", (c-a), " ", (b - a).dot(c - a))
	return 0.5 * abs((b - a).cross(c - a))
	
func random_point_in_triangle(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
	var a2b: Vector2 = b - a
	var a2c: Vector2 = c - a
	
	var u1: float = rand.randf()
	var u2: float = rand.randf()
	if u1 + u2 > 1:
		u1 = 1.0 - u1
		u2 = 1.0 - u2
	
	return a + (u1 * a2b) + (u2 * a2c)
