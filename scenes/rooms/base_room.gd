class_name BaseRoom
extends Node3D
@onready var cellings: GridMap = $Celling
@onready var floors: GridMap = $GridMap
var cell_ids_with_ceiling:=[]
var celling_id:int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fill_ceilings()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func fill_ceilings():
	celling_id=cellings.mesh_library.find_item_by_name("celling")
	for cell_name:String in ["Ground","Hole-Cornor","Hole-Ground","Hole-Side_","Hole-U-Cornor","platform"]:
		cell_ids_with_ceiling.push_back(floors.mesh_library.find_item_by_name(cell_name))
	var used_cells:Array[Vector3i]=floors.get_used_cells()
	for cell_coords in used_cells:
		var tile_id:int=floors.get_cell_item(cell_coords)
		if cell_ids_with_ceiling.has(tile_id):
			cellings.set_cell_item(cell_coords,celling_id)
