extends Spatial
class_name Disk

#var speed := 5.0
var number: int

func _physics_process(delta: float) -> void:
	self.global_transform.origin += Game.speed * delta * Vector3.FORWARD
	if Input.is_action_just_pressed("force_check"):
		check()

func get_image() -> Image:
	return $Sprite3D.texture.get_data()

func set_image(im):
	if im is StreamTexture:
		$Sprite3D.texture = im
		$Sprite3D.material_override.set("shader_param/texture_albedo", im)
		$SplashCover.material_override.set("shader_param/texture_albedo", im)
		return
	var texture = ImageTexture.new()
	texture.create_from_image(im)
	$Sprite3D.texture = texture
	$Sprite3D.material_override.set("shader_param/texture_albedo", texture)
	$SplashCover.material_override.set("shader_param/texture_albedo", texture)

func load_disk_from_file(disk_number):
	var folder = "res://Disks/" if not Game.hard_levels else "res://Disks/Hard/"
	var file_name = folder + str(disk_number) + ".png"
	var image_loaded = load(file_name)
	set_image(image_loaded)

func discard():
	#yield(get_tree().create_timer(1), "timeout")
	$Tween.interpolate_property($Sprite3D.material_override, "shader_param/albedo", Color.white, Color.transparent, 0.4)
	$Tween.start()
	yield(get_tree().create_timer(3.5), "timeout")
	queue_free()

var cross_origin := Vector2(256, 476)
var cross_radius := 26
func check():
	var im = get_image()
	var test_pixels = [cross_origin]
	for i in range(int(cross_radius/2)):
		test_pixels.append(cross_origin + 2*i*Vector2(0,1))
		test_pixels.append(cross_origin + 2*i*Vector2(0,-1))
		test_pixels.append(cross_origin + 2*i*Vector2(1,0))
		test_pixels.append(cross_origin + 2*i*Vector2(-1,0))
	for i in range(int(.7*cross_radius/2)):
		test_pixels.append(cross_origin + 2*i*Vector2(1,1))
		test_pixels.append(cross_origin + 2*i*Vector2(1,-1))
		test_pixels.append(cross_origin + 2*i*Vector2(-1,1))
		test_pixels.append(cross_origin + 2*i*Vector2(-1,-1))
	im.lock()
	for v in test_pixels:
		if im.get_pixelv(v) == Color.white:
			im.unlock()
			return false
	im.unlock()
	return true

func splash_start(cursor_pixel, rotation_rads):
	$SplashYellow.visible = true
	$SplashCover.visible = true
	var texture = ImageTexture.new()
	texture.create_from_image(get_image())
	$SplashYellow.material_override.set("shader_param/texture_albedo", texture)
	$SplashYellow.material_override.set("shader_param/transparent", 1.0)
	$SplashCover.material_override.set("shader_param/albedo", Color.white)
	$SplashCover.material_override.set("shader_param/cursor", cursor_pixel/Game.image_res)
	$SplashCover.material_override.set("shader_param/cursor_normal", Vector2.UP.rotated(rotation_rads))
	$SplashCover.material_override.set("shader_param/colors_inverted", false)
	$SplashTween.interpolate_property($SplashCover.material_override, "shader_param/splash_progress", 0.0, 1.0, .4)
	$SplashTween.start()
#	yield($SplashTween,"tween_all_completed")
#	$SplashTween.interpolate_property($SplashCover.material_override, "shader_param/splash_progress", 1.0, 0.0, .4)
#	$SplashCover.material_override.set("shader_param/colors_inverted", true)
#	$SplashTween.start()


func splash_end(im):
	set_image(im)
	$YellowTween.interpolate_property($SplashYellow.material_override, "shader_param/fade_to_yellow", 0.0, .5, .15, Tween.TRANS_CUBIC,Tween.EASE_IN)
	$YellowTween.start()
	yield($YellowTween,"tween_all_completed")
	$YellowTween.interpolate_property($SplashYellow.material_override, "shader_param/transparent", 1.0, 0.0, .2)
	$YellowTween.start()
	yield($YellowTween,"tween_all_completed")
	$SplashTween.reset_all()
	$SplashTween.interpolate_property($SplashYellow.material_override, "shader_param/modulate", 1.0, 0.0, .25)
	$SplashTween.interpolate_property($SplashCover.material_override, "shader_param/modulate", 1.0, 0.0, .25)
	$SplashTween.start()
	yield($SplashTween, "tween_all_completed")
	

	$SplashCover.visible = false
	$SplashYellow.visible = false
	
	$SplashYellow.material_override.set("shader_param/modulate", 1.0)
	$SplashCover.material_override.set("shader_param/modulate", 1.0)
