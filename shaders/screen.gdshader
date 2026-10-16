shader_type canvas_item;


uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform float intensity: hint_range(0,1) = 1.0;

vec4 screen(vec4 base, vec4 blend){
  return 1.0 - (1.0 - base) * (1.0 - blend);
}

void fragment(){
  // COLOR.rgb = screen( bg_color, COLOR ).rgb;
}