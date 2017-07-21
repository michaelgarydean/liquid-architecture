// Liquid Architecture
// Particle Sprite Rendering Fragment Shader
// MAT shader for particle sprites with positional audio data

uniform sampler2D sColorRamp; // gradient for sound based coloring
uniform sampler2D sSpriteTex;

uniform float uSpotlightBlend;

// each uSoundN vector stores xyz position of the sound + amplitude value
uniform vec4 uSound1;

in Vertex {
	vec4 color;
	vec3 camSpaceVert;
	vec3 camVector;
	vec3 norm;
} vVert;

in float soundDistance;

// Output variable for the color
layout(location = 0) out vec4 fragColor[TD_NUM_COLOR_BUFFERS];


// ---------------------------------------------------------------------------

// picks a color from the sColorRamp gradient using the dist as vertical texture coordinate
// applies alpha using magnitude
vec4 applyColorRamp(vec4 color, float dist, float magnitude) {
	vec4 rampColor = texture(sColorRamp, vec2(0.5, clamp(dist,0.0,1.0)));
    return mix(color, vec4(rampColor.rgb, (1.0-dist)*magnitude), uSpotlightBlend);
}

// ---------------------------------------------------------------------------
void main()
{
	TDCheckDiscard(); // discard unused pixels
    vec4 color = applyColorRamp(vVert.color, soundDistance, clamp(uSound1.w, 0.0, 1.0));
    vec2 pointUVs = -gl_PointCoord;
    vec4 texture = texture(sSpriteTex, pointUVs);
	fragColor[0] = TDOutputSwizzle(texture * color);
}
