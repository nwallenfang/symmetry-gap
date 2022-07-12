extends Node

var meter_per_pixel := 27.782/512.0
var tube_scale := 27.782
var image_res := 512
var disk_number = 1

var level_count = 20

var current_disk : Disk setget set_current_disk
var symmetrizer
var tunnel
var ui

var speed := 12.0 # meter / second
var start_speed := 12.0
var accel := .7

var tutorials := {
	1: "Press SPACE\nto create symmetry",
	2: "Press Q/E\nto rotate the axis",
	4: "Another Tutorial Text",
	9: "Press WASD\nto move the axis",
	13: "Sometimes you need to\nsymmetrize more than once"
}

var level_data_dict := { #symm count, can_rotate, can_move, cursor_reset_location, cursor_reset_rotation
	1: [1, false, false, null, null],
	2: [1, true, false, null, null],
	3: [1, true, false, null, null],
	4: [1, true, false, null, null],
	5: [1, true, false, null, null],
	6: [1, true, false, null, null],
	7: [1, true, false, null, null],
	8: [1, true, false, null, null],
	9: [1, true, true, null, null],
	10: [1, true, true, null, null],
	11: [1, true, true, null, null],
	12: [1, true, true, null, null],
	13: [2, true, true, null, null],
	14: [3, true, true, null, null],
	15: [3, true, true, null, null],
	16: [2, true, true, null, null],
	17: [2, true, true, null, null],
	18: [3, true, true, null, null],
	19: [3, true, true, null, null],
	20: [1, true, true, null, null],
}

var available_symms: int setget set_available_symms
var can_rotate := false
var can_move := false

func set_available_symms(x):
	available_symms = x
	ui.show_available_symms(x)
	if x == 0:
		can_move = false
		can_rotate = false

func _ready() -> void:
	pass 

func set_current_disk(disk: Disk):
	current_disk = disk
	if symmetrizer != null:
		symmetrizer.selected_disk = disk
	if disk == null:
		return
	var level_data = level_data_dict[disk.number]
	self.available_symms = level_data[0]
	can_rotate = level_data[1]
	can_move = level_data[2]
	if level_data[3] != null:
		symmetrizer.cursor.translation = level_data[3]
	if level_data[4] != null:
		symmetrizer.cursor.rotation_degrees.z = level_data[4]
		
