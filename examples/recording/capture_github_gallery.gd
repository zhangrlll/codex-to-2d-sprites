extends SceneTree

const DIRECTIONS := ["s", "se", "e", "ne", "n", "nw", "w", "sw"]
var players: Array = []

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1024, 560)
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var background := ColorRect.new()
	background.color = Color("dce5ce")
	background.size = Vector2(1024, 560)
	viewport.add_child(background)
	for i in 8:
		var player = load("res://scenes/player.tscn").instantiate()
		viewport.add_child(player)
		player.set_physics_process(false)
		player.sprite.set_process(false)
		player.position = Vector2(i % 4 * 256 + 128, i / 4 * 280 + 254)
		players.append(player)
		var label := Label.new()
		label.text = DIRECTIONS[i].to_upper()
		label.position = Vector2(i % 4 * 256 + 12, i / 4 * 280 + 7)
		label.add_theme_color_override("font_color", Color("263e33"))
		viewport.add_child(label)
	var counts := {}
	for action in ["idle", "walk", "run", "roll", "jump"]:
		var total := 3.2 if action == "idle" else 0.0
		if action != "idle":
			for frame in 12:
				total += players[0].sprite.sprite_frames.get_frame_duration(action + "_s", frame)
		var count := ceili(total * 30.0)
		var folder := ProjectSettings.globalize_path("res://../ShowcaseRecording/gallery/" + action)
		DirAccess.make_dir_recursive_absolute(folder)
		for i in 8:
			players[i].state = action
			players[i].sprite.play(action + "_" + DIRECTIONS[i])
			players[i].sprite.pause()
		for index in count:
			var time := float(index) / 30.0
			for i in 8:
				var sprite = players[i].sprite
				var frame := 0
				var left := time
				while action != "idle" and frame < 11 and left >= sprite.sprite_frames.get_frame_duration(sprite.animation, frame):
					left -= sprite.sprite_frames.get_frame_duration(sprite.animation, frame)
					frame += 1
				sprite.set_frame_and_progress(frame, left / sprite.sprite_frames.get_frame_duration(sprite.animation, frame))
				sprite.idle_time = time
				sprite.refresh_details()
			await process_frame
			await RenderingServer.frame_post_draw
			viewport.get_texture().get_image().save_png(folder + "/%03d.png" % index)
		counts[action] = count
	var file := FileAccess.open("res://../ShowcaseRecording/gallery_manifest.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"fps": 30, "frames": counts, "directions": DIRECTIONS, "source": "actual Godot shader renders"}, "\t"))
	print("GALLERY PASS: ", counts)
	quit()
