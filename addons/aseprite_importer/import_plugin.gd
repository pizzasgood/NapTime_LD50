tool
extends EditorImportPlugin


enum Presets { PRESET_DEFAULT }


func get_importer_name():
	return "aseprite_importer"


func get_visible_name():
	return "Aseprite Sprite"


func get_recognized_extensions():
	return ["ase", "aseprite"]


func get_save_extension():
	return "tres"


func get_resource_type():
	return "SpriteFrames"


func get_preset_count():
	return Presets.size()


func get_preset_name(preset):
	match preset:
		Presets.PRESET_DEFAULT:
			return "Default"
		_:
			return "Unknown"


func get_import_options(preset):
	match preset:
		Presets.PRESET_DEFAULT:
			return [
				{"name": "mipmaps", "default_value": true},
				{"name": "repeat", "default_value": true},
				{"name": "filter", "default_value": false},
				{"name": "anisotropic_filter", "default_value": false},
				{"name": "convert_to_linear", "default_value": false},
				{"name": "mirrored_repeat", "default_value": false},
				{"name": "video_surface", "default_value": false},
			]
		_:
			return []


func get_option_visibility(option, options):
	return true


func validate_data(data):
	if not "meta" in data:
		printerr("%s: 'meta' section missing from JSON" % get_importer_name())
		return false
	if not "frameTags" in data["meta"]:
		printerr("%s: 'frameTags' section missing from JSON" % get_importer_name())
		return false
	if not "format" in data["meta"]:
		printerr("%s: 'format' section missing from JSON" % get_importer_name())
		return false
	if not "frames" in data:
		printerr("%s: 'frames' section missing from JSON" % get_importer_name())
		return false
	if not data["frames"] is Array:
		printerr("%s: 'frames' section of JSON is not an array" % get_importer_name())
		return false
	return true


func import(source_file, save_path, options, platform_variants, gen_files):
	var data_file = "%s.json" % save_path
	var img_file = "%s.png" % save_path

	# Export the sprite data
	var aseprite_bin = "aseprite"
	var aseprite_options = [
		"--batch",
		source_file.replace("res://", ""),
		"--sheet", img_file.replace("res://", ""),
		"--data", data_file.replace("res://", ""),
		"--format", "json-array",
		"--list-tags",
		"--trim",
	]
	var ret = OS.execute(aseprite_bin, aseprite_options)
	if ret != 0:
		printerr("%s: %s returned with non-zero exit code %s" % [get_importer_name(), aseprite_bin, ret])
		return ERR_PARSE_ERROR

	# Read the JSON data
	var file = File.new()
	var err = file.open(data_file, File.READ)
	if err != OK:
		printerr("%s: Opening %s failed with error %s" % [get_importer_name(), data_file, err])
		return err
	var raw_data = file.get_as_text()
	file.close()
	if validate_json(raw_data):
		printerr("%s: Data in %s not valid JSON" % [get_importer_name(), data_file])
		return ERR_PARSE_ERROR
	var data = parse_json(raw_data)
	if not validate_data(data):
		printerr("%s: Invalid data in %s" % [get_importer_name(), data_file])
		return ERR_PARSE_ERROR

	# Load the spritesheet
	var source_image = Image.new()
	err = source_image.load(img_file)
	if err != OK:
		printerr("%s: Loading %s failed with error %s" % [get_importer_name(), img_file, err])
		return err

	# Extract the frames
	var frame_textures = []
	for frame in data["frames"]:
		var size = Vector2(frame["sourceSize"]["w"], frame["sourceSize"]["h"])
		var source = Rect2(frame["frame"]["x"], frame["frame"]["y"], frame["frame"]["w"], frame["frame"]["h"])
		var dest = Vector2(frame["spriteSourceSize"]["x"], frame["spriteSourceSize"]["y"])
		var image = Image.new()
		image.create(size.x, size.y, true, source_image.get_format())
		image.blit_rect(source_image, source, dest)
		var texture = ImageTexture.new()
		texture.create_from_image(image, image_format(options))
		frame_textures.append(texture)

	# Initialize the SpriteFrames and remove any default animations
	var sprite_frames = SpriteFrames.new()
	for name in sprite_frames.get_animation_names():
		sprite_frames.remove_animation(name)

	# Load the animations
	for anim in data["meta"]["frameTags"]:
		sprite_frames.add_animation(anim["name"])
		sprite_frames.set_animation_speed(anim["name"], 1000.0 / data["frames"][anim["from"]]["duration"])
		var used_frames
		match(anim["direction"]):
			"forward":
				used_frames = range(anim["from"], anim["to"]+1)
			"reverse":
				used_frames = range(anim["to"], anim["from"]-1, -1)
			"pingpong":
				used_frames = range(anim["from"], anim["to"]+1) + range(anim["to"]-1, anim["from"], -1)
			_:
				printerr("%s: Unknown direction %s in JSON" % [get_importer_name(), anim["direction"]])
		for i in used_frames:
			sprite_frames.add_frame(anim["name"], frame_textures[i])

	# Save the SpriteFrames resource and get out of here
	return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], sprite_frames)


func image_format(options):
	var format = 0
	if options.mipmaps:
		format += ImageTexture.FLAG_MIPMAPS
	if options.repeat:
		format += ImageTexture.FLAG_REPEAT
	if options.filter:
		format += ImageTexture.FLAG_FILTER
	if options.anisotropic_filter:
		format += ImageTexture.FLAG_ANISOTROPIC_FILTER
	if options.convert_to_linear:
		format += ImageTexture.FLAG_CONVERT_TO_LINEAR
	if options.mirrored_repeat:
		format += ImageTexture.FLAG_MIRRORED_REPEAT
	if options.video_surface:
		format += ImageTexture.FLAG_VIDEO_SURFACE

	return format
