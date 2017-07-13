// Liquid Architecture
// Particle Sprite Rendering Fragment Shader
// MAT shader for particle sprites with positional audio data

uniform sampler2D sColorRamp; // gradient for sound based coloring

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
	vec4 rampColor = texture(sColorRamp, vec2(0.5, dist));
    return vec4(rampColor.rgb, 1.0-(dist/magnitude));//mix(vec4(color.rgb, dist), vec4(rampColor.rgb, rampColor.a * dist), uSound1.w);
}

// ---------------------------------------------------------------------------
void main()
{
	TDCheckDiscard(); // discard unused pixels

    vec4 color = applyColorRamp(vVert.color, soundDistance, uSound1.w);
	fragColor[0] = color;
}
