embedded_components {
  id: "sprite"
  type: "sprite"
  data: "tile_set: \"/main/source/hex.atlas\"\n"
  "default_animation: \"empty0\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 0.0
    y: 0.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "highlight_front"
  type: "sprite"
  data: "tile_set: \"/main/source/highlight.atlas\"\n"
  "default_animation: \"highlight_front\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 0.0
    y: 0.0
    z: 0.1001
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
