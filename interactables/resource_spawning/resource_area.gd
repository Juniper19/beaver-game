#@tool
class_name ResourceArea
extends Polygon2D


@export_range(0.0, 100.0) var oak_density: float = 0.0
@export_range(0.0, 100.0) var aspen_density: float = 0.0
@export_range(0.0, 100.0) var pine_density: float = 0.0
@export_range(0.0, 100.0) var stone_density: float = 0.0
#@export_tool_button("Visualize") var _vis = _visualize


const MAX_TRIES: int = 10

const TREE = preload("uid://cd3s2mygwd6ul")
const OAK_TREE = preload("uid://dps300dufah0")
const ASPEN_TREE = preload("uid://de4jpe12kbg52")
const PINE_TREE = preload("uid://coq60gmhpggti")

const ROCK = preload("uid://fbvlq216070u")

#func _visualize():
	#for child in get_children():
		#child.queue_free()
	#spawn_resources(self)


func spawn_resources(parent_node: Node):
	if !polygon:
		return
	
	var spawn_area = SpawnArea.new(polygon)
	var area: float = spawn_area.cumulative_areas.back()
	@warning_ignore("narrowing_conversion")
	var oak_to_spawn: int = area * oak_density / 250_000.0
	@warning_ignore("narrowing_conversion")
	var aspen_to_spawn: int = area * aspen_density / 250_000.0
	@warning_ignore("narrowing_conversion")
	var pine_to_spawn: int = area * pine_density / 250_000.0
	@warning_ignore("narrowing_conversion")
	var stone_to_spawn: int = area * stone_density / 250_000.0
	
	
	
	for i in stone_to_spawn:
		var point: Vector2 = _get_point(spawn_area)
		if !point.is_finite():
			return
		var rock: PhysicalRock = ROCK.instantiate()
		parent_node.add_child(rock)
		rock.global_position = point

	oak_to_spawn = spawn_area.cumulative_areas.back() * oak_density / 250_000.0
	print(oak_to_spawn)

	#for i in oak_to_spawn:
		#_spawn_tree(spawn_area, OAK_TREE, parent_node)
		
	for pt in spawn_area.n_points(oak_to_spawn):
		_spawn_tree_2(pt, OAK_TREE, parent_node)
	
	for i in aspen_to_spawn:
		_spawn_tree(spawn_area, ASPEN_TREE, parent_node)
	
	for i in pine_to_spawn:
		_spawn_tree(spawn_area, PINE_TREE, parent_node)


func _spawn_tree(spawn_area: SpawnArea, data: TreeData, parent_node: Node):
	var point: Vector2 = _get_point(spawn_area)
	if !point.is_finite():
		return
	var tree: PhysicalTree = TREE.instantiate()
	tree.data = data
	parent_node.add_child(tree)
	tree.global_position = point

func _spawn_tree_2(point: Vector2, data: TreeData, parent_node: Node):
	var tree: PhysicalTree = TREE.instantiate()
	tree.data = data
	parent_node.add_child(tree)
	tree.global_position = point + global_position

func _get_point(spawn_area: SpawnArea) -> Vector2:
	for i in MAX_TRIES:
		var point: Vector2 = spawn_area.random_point() + global_position
		
		var space := get_world_2d().direct_space_state

		var shape := RectangleShape2D.new()
		shape.size = Vector2(64, 64)

		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D(0, point)
		query.collide_with_areas = true
		query.collide_with_bodies = true

		if !space.intersect_shape(query):
			return point
	
	return Vector2.INF
