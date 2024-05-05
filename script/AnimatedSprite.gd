extends Node

@onready var sprite_manager = $"."
@onready var sprite_2d = $Sprite2D
@onready var sprite_info = JSON.parse_string(FileAccess.get_file_as_string(sprite_manager.get_meta("AnimationJsonPath")))
@onready var sprites = {}
@onready var currentAnimation = "idle"
@onready var basePosition = {}


func _ready():
	for part in sprite_info.parts:
		var bounds = sprite_info.parts[part].bounds
		createPartSprite(part, bounds.x, bounds.y, bounds.width, bounds.height)

	positionSprites()
	setAnimation(currentAnimation, true);


func _process(delta):
	update_animation()


func createPartSprite(part, x, y, width, height):
	var sprite = Sprite2D.new()
	var atlas_texture = AtlasTexture.new()

	atlas_texture.atlas = sprite_2d.texture
	atlas_texture.region = Rect2(x, y, width, height)

	sprite.texture = atlas_texture
	sprite_manager.add_child(sprite)
	sprites[part] = sprite


func setAnimation(animation, force):
	if !force and currentAnimation == animation:
		return

	currentAnimation = animation;

	for part in sprite_info.parts:
		var parts = sprite_info.states[animation].visibleParts
		sprites[part].visible = parts.has(part);


func positionSprites():
	for part in sprite_info.parts:
		var bounds = sprite_info.parts[part].bounds
		var origin = sprite_info.parts[part].origin
		var anchor = sprite_info.parts[part].anchor
		var z_index = sprite_info.parts[part].zIndex
		
		sprites[part].position.x = origin.x
		sprites[part].position.y = origin.y
		sprites[part].z_index = z_index
		sprites[part].offset.x = (bounds.width * 0.5) - anchor.x * bounds.width
		sprites[part].offset.y = (bounds.height * 0.5) -anchor.y * bounds.height

#    
	basePosition = {};
	for state in sprite_info.states:
		basePosition[state] = [];
		for animation in sprite_info.states[state].animations:
			var type = animation.type
			var parts = animation.parts
			var partsPositions = {}

			for part in parts:
				if type == "x":
					partsPositions[part] = sprites[part].position.x
				elif type == "y":
					partsPositions[part] = sprites[part].position.y
				elif type == "rotation":
					partsPositions[part] = 0

			basePosition[state].append(partsPositions);


func update_animation():
	var time = Time.get_ticks_msec()
	
	for state in sprite_info.states:
		if state != currentAnimation: continue
		var animations = sprite_info.states[state].animations

		for i in range(len(animations)):
			var animation = animations[i]
			var currentSin = sin((time / 1000.0) * animation.speed);

			for j in range(len(animation.parts)):
				var part = animation.parts[j]
				var invert = -1 if animation.inverted[j] else 1
				var initial = basePosition[state][i][part];

				if animation.type == "x":
					sprites[part].position.x = initial + currentSin * animation.amplitude * invert
				elif animation.type == "y":
					sprites[part].position.y = initial + currentSin * animation.amplitude * invert
				elif animation.type == "rotation":
					sprites[part].rotation = currentSin * animation.amplitude * (PI / 180) * invert

