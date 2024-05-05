extends Node

@onready var sprite_manager = $"."
@onready var sprite_2d = $Sprite2D
@onready var sprite_info = JSON.parse_string(FileAccess.get_file_as_string(sprite_manager.get_meta("AnimationJsonPath")))
@onready var sprites = {}

@onready var currentAnimation = "idle"

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
		
#      const { width, height } = this._info.parts[part].bounds;
#      const { x: originX, y: originY } = this._info.parts[part].origin;
#      const { x: anchorX, y: anchorY } = this._info.parts[part].anchor;
#      const zIndex = this._info.parts[part].zIndex;
#
#      this._sprites[part].width = width * this._pixel * tile;
#      this._sprites[part].height = height * this._pixel * tile;
#      this._sprites[part].x = originX * this._pixel * tile;
#      this._sprites[part].y = originY * this._pixel * tile;
#      this._sprites[part].anchor.set(anchorX, anchorY);
#      this._sprites[part].zIndex = zIndex;
#    }
#
#    // Set initial positions
#    this._basePosition = {};
#
#    for (const state in this._info.states) {
#      this._basePosition[state] = [];
#
#      for (const animation of this._info.states[state].animations) {
#        const { parts, type } = animation;
#        const partsPositions: { [key: string]: number } = {};
#
#        for (const part of parts) {
#          if (type === 'x') partsPositions[part] = this._sprites[part].x;
#          else if (type === 'y') partsPositions[part] = this._sprites[part].y;
#          else if (type === 'rotation') partsPositions[part] = 0;
#        }
#
#        this._basePosition[state].push(partsPositions);
#      }
#    }
#  }

func update_animation():
	pass
