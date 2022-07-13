extends Spatial

var selected_disk: Disk
var currently_symmetrizing = false

onready var cursor = $Cursor

var bool_data := {} # map vec2 -> bool

func set_pixel_data(x, y):
	#if min(x, y) >= 0 and max(x, y) < Game.image_res:
	bool_data[Vector2(x,y)] = true

func set_pixel_area(x, y):
	set_pixel_data(x+1,y+1)
	set_pixel_data(x+1,y)
	set_pixel_data(x+1,y-1)
	set_pixel_data(x,y+1)
	set_pixel_data(x,y)
	set_pixel_data(x,y-1)
	set_pixel_data(x-1,y+1)
	set_pixel_data(x-1,y)
	set_pixel_data(x-1,y-1)

var number_of_frames = 30  # to spread the workload over
func calc_symm(im: Image, cursor_pos: Vector2, rotation: float): #  -> Image:
	var res = Game.image_res

	var result : Image = Image.new()
	result.create(res, res, false, Image.FORMAT_RGBA8)
	bool_data = {}

	yield(get_tree(), "idle_frame")

	var rotation_vec := Vector2.LEFT.rotated(rotation)
	var rows_this_frame = 0
	var rows_per_frame = int(res/number_of_frames)
	
	result.fill(Color.white)
	yield(get_tree(), "idle_frame")
	im.lock()
	for i in range(res):
		if rows_this_frame >= rows_per_frame:
			rows_this_frame = 0
			yield(get_tree(), "idle_frame")
		for j in range(res):
			if im.get_pixel(i, j) == Color.black:
				set_pixel_area(i, j)
				var pos = Vector2(i, j)
				var mirrored = (pos - cursor_pos).reflect(rotation_vec) + cursor_pos
				if mirrored.x < Game.image_res-1 and mirrored.x > 0 and mirrored.y < Game.image_res-1 and mirrored.y > 0:
					set_pixel_area(mirrored.x, mirrored.y)
		rows_this_frame += 1
	im.unlock()
	yield(get_tree(), "idle_frame")
	var counter = 0
	result.lock()
	print(len(bool_data))
	for xy in bool_data.keys():
		var x = int(xy.x)
		var y = int(xy.y)
		if min(x, y) < 0 or max(x, y) >= Game.image_res:
			continue
		counter += 1
		if counter >= 20000:
			counter = 0
			yield(get_tree(), "idle_frame")
		if bool_data[xy]:
			result.set_pixel(xy[0], xy[1], Color.black)
	result.unlock()

	return result

func symmetrize_done(result):
	#selected_disk.set_image(result)
	selected_disk.splash_end(result)
	yield(get_tree().create_timer(.3),"timeout")
	Game.available_symms -= 1
	currently_symmetrizing = false

var cursor_speed_pixels := 300.0
var cursor_speed_rotation_degrees := 90.0
var cursor_max_distance := 10.0
func _physics_process(delta):
	if selected_disk != null:
		self.global_transform.origin = selected_disk.global_transform.origin + Vector3(0.0, 0.0, -.5)
	if Game.can_move:
		if Input.is_action_pressed("cursor_move_up"):
			$Cursor.translation.y += cursor_speed_pixels * Game.meter_per_pixel * delta
		if Input.is_action_pressed("cursor_move_down"):
			$Cursor.translation.y -= cursor_speed_pixels * Game.meter_per_pixel * delta
		if Input.is_action_pressed("cursor_move_left"):
			$Cursor.translation.x += cursor_speed_pixels * Game.meter_per_pixel * delta
		if Input.is_action_pressed("cursor_move_right"):
			$Cursor.translation.x -= cursor_speed_pixels * Game.meter_per_pixel * delta
	if Game.can_rotate:
		if Input.is_action_pressed("cursor_rotate_clock"):
			$Cursor.rotation_degrees.z += cursor_speed_rotation_degrees * delta
		if Input.is_action_pressed("cursor_rotate_counter"):
			$Cursor.rotation_degrees.z -= cursor_speed_rotation_degrees * delta
	if $Cursor.translation.length() > cursor_max_distance:
		$Cursor.translation *= cursor_max_distance / $Cursor.translation.length()
	if Input.is_action_just_pressed("symmetrize"):
		# TODO only call calc_symm if there isn't an ongoing calc_symm at the moment
		if (not currently_symmetrizing) and is_instance_valid(selected_disk):
			if Game.available_symms > 0:
				var cursor_position_pixel = Vector2.ONE * Game.image_res * .5 + Vector2(-$Cursor.translation.x, -$Cursor.translation.y) / Game.meter_per_pixel
				var cursor_rotation_radians = deg2rad($Cursor.rotation_degrees.z)
				var image = selected_disk.get_image()
				var func_state = calc_symm(image, cursor_position_pixel, cursor_rotation_radians)
				selected_disk.splash_start(cursor_position_pixel, cursor_rotation_radians)
				func_state.connect("completed", self, "symmetrize_done")
				currently_symmetrizing = true

