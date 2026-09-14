extends SceneTree

# Drive the existing scene through its real input actions; only reset between labeled takes.
const DIRECTIONS := ["s", "se", "e", "ne", "n", "nw", "w", "sw"]
const KEYS := {
	"s": ["move_down"], "se": ["move_down", "move_right"], "e": ["move_right"],
	"ne": ["move_up", "move_right"], "n": ["move_up"], "nw": ["move_up", "move_left"],
	"w": ["move_left"], "sw": ["move_down", "move_left"]
}
var player
var caption: Label
var detail: Label
var chapter := "intro"
var records: Array = []
var chapters: Array = []
var failures: Array[String] = []
var output: String

func _initialize() -> void:
	call_deferred("run")

func release_keys() -> void:
	for key in ["move_up", "move_down", "move_left", "move_right", "sprint", "roll", "jump"]:
		Input.action_release(key)

func direction_keys(direction: String) -> void:
	for key in KEYS[direction]:
		Input.action_press(key)

func frames(count: int) -> void:
	for i in count:
		await process_frame
		await RenderingServer.frame_post_draw
		var sprite = player.sprite
		var region: Rect2 = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame).region
		records.append({"movie_frame": Engine.get_frames_drawn(), "chapter": chapter,
			"state": player.state, "facing": player.facing, "animation": String(sprite.animation),
			"source_pose": int(region.position.x / 256), "x": player.position.x, "y": player.position.y,
			"speed": player.velocity.length(), "breath": sprite.stable_material.get_shader_parameter("idle_breath")})

func label_take(action: String, direction: String, extra := "") -> void:
	chapter = action + "_" + direction
	chapters.append({"id": chapter, "start_seconds": float(Engine.get_frames_drawn()) / 30.0})
	caption.text = action.to_upper() + "   /   " + direction.to_upper() + "   " + extra
	detail.text = "S  SE  E  NE  N  NW  W  SW    |    " + str(DIRECTIONS.find(direction) + 1) + " / 8"

func prepare(direction: String, travel: float) -> void:
	release_keys()
	player.reset_player()
	player.position = Vector2(640, 540) - player.VECTORS[direction] * travel * 0.5
	direction_keys(direction)
	await frames(2)
	release_keys()
	await frames(2)
	if player.facing != direction or player.velocity.length() > 0.1:
		failures.append("Orientation failed: " + direction)

func run() -> void:
	output = ProjectSettings.globalize_path("res://../ShowcaseRecording")
	DirAccess.make_dir_recursive_absolute(output)
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	player = scene.get_node("Player")
	var overlay := CanvasLayer.new()
	overlay.layer = 20
	scene.add_child(overlay)
	caption = Label.new()
	caption.position = Vector2(44, 184)
	caption.add_theme_font_size_override("font_size", 24)
	caption.add_theme_color_override("font_color", Color("c8ee93"))
	caption.text = "8 DIRECTIONS  /  5 ACTIONS"
	overlay.add_child(caption)
	detail = Label.new()
	detail.position = Vector2(690, 193)
	detail.add_theme_font_size_override("font_size", 15)
	detail.add_theme_color_override("font_color", Color("b5c8c5"))
	detail.text = "REAL GODOT SCENE  /  SCRIPTED INPUT  /  30 FPS"
	overlay.add_child(detail)
	await frames(45)
	for action in ["idle", "walk", "run", "roll", "jump"]:
		for direction in DIRECTIONS:
			label_take(action, direction)
			var travel := 200.0 if action in ["run", "roll"] else (85.0 if action == "walk" else 0.0)
			await prepare(direction, travel)
			if action in ["walk", "run"]:
				direction_keys(direction)
				if action == "run":
					Input.action_press("sprint")
				await frames(39 if action == "walk" else 21)
			elif action in ["roll", "jump"]:
				Input.action_press(action)
				await frames(1)
				Input.action_release(action)
				await frames(56 if action == "roll" else 50)
			else:
				await frames(99)
			release_keys()
			await frames(12)
	# Moving combinations showcase the trimmed anticipation/recovery clips in real play.
	for gait in ["walk", "run"]:
		for special in ["roll", "jump"]:
			label_take(gait + " + " + special, "e", "  /  MOVING TRANSITION")
			detail.text = "CONTINUE MOVING  /  NO STANDING PADDING"
			await prepare("e", 0.0)
			player.position = Vector2(350, 540)
			direction_keys("e")
			if gait == "run":
				Input.action_press("sprint")
			await frames(12)
			Input.action_press(special)
			await frames(1)
			Input.action_release(special)
			await frames(36)
			release_keys()
			await frames(15)
	release_keys()
	player.reset_player()
	chapter = "outro"
	caption.text = "GPT IMAGE  >  TRIPO AI  >  CODEX SKILL  >  GODOT"
	detail.text = ""
	await frames(60)
	for action in ["idle", "walk", "run", "roll", "jump"]:
		for direction in DIRECTIONS:
			var matched := 0
			for record in records:
				if record.chapter == action + "_" + direction and record.state == action and record.facing == direction:
					matched += 1
			if matched < 10:
				failures.append("Missing recorded action: " + action + "_" + direction)
	var rendered_size := root.get_texture().get_size()
	var result := {"fps": 30, "resolution": [int(rendered_size.x), int(rendered_size.y)], "source_scene": "scenes/main.tscn",
		"control": "Real Input actions; position resets only between labeled takes", "chapters": chapters,
		"records": records, "failures": failures, "full_action_direction_combinations": 40}
	var file := FileAccess.open(output + "/recording_manifest.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(result, "\t"))
	file.close()
	print("RECORDING ", "PASS" if failures.is_empty() else "FAIL", ": 40 action/direction combinations; 4 moving chains; ", records.size(), " frames; ", failures)
	quit(0 if failures.is_empty() else 1)
