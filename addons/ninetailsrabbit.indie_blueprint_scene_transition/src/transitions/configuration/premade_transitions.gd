class_name IndieBlueprintPremadeTransitions extends RefCounted
	
const ColorFade: StringName = &"color_fade"
const Voronoi: StringName = &"voronoi"
const Dissolve: StringName = &"dissolve"


#region Dissolve available textures
const BlurryNoise: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/blurry-noise.png")
const CellNoise: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/cell-noise.png")
const CircleInverted: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/circle-inverted.png")
const Circle: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/circle.png")
const Conical: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/conical.png")
const Curtains: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/curtains.png")
const HorizontalPaintBrush: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/horiz_paint_brush.png")
const NoisePixelated: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/noise-pixelated.png")
const NormalNoise: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/noise.png")
const Scribbles: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/scribbles.png")
const Square: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/square.png")
const Squares: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/squares.png")
const Swirl: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/swirl.png")
const TileReveal: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/tile_reveal.png")
const VerticalPaintBrush: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/vertical_paint_brush.png")
const WipeDown: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/wipe-down.png")
const WipeLeft: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/wipe-left.png")
const WipeRight: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/wipe-right.png")
const WipeUp: CompressedTexture2D = preload("res://addons/ninetailsrabbit.indie_blueprint_scene_transition/src/transitions/dissolve/textures/wipe-up.png")
#endregion
