shader_type canvas_item;


uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
//uniform float intensity: hint_range(0,1) = 1.0;
//uniform vec4 color_input : source_color;
uniform float ATMOSPHERIC_MULTIPLIER;

vec4 screen(vec4 base, vec4 Multiplier, vec4 blend){
  return (base * Multiplier) + blend;
}

void fragment(){
	// mix() if you want to be able to set 'intensity' to different values.
	//COLOR.rgb = mix(COLOR, screen(bg_color, COLOR), intensity).rgb;

	// No need to mix() if you always want 'intensity' to be 1.0 (uncomment):
	float val = ATMOSPHERIC_MULTIPLIER;
	float ro = -40.0 * val;
	float go = -18.0 * val;
	float bo = -25.0 * val;
	vec4 offset = vec4(ro, go, bo, 1.0);

	float rm = 1.0 - (0.65 * val);
	float gm = 1.0 - (0.40 * val);
	float bm = 1.0 - (0.55 * val);
	vec4 multiplier = vec4(rm, gm, bm, 1.0);
  COLOR.rgb = screen(COLOR, multiplier, offset).rgb;
}