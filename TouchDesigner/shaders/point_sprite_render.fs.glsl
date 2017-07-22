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
    //vec3 worldSpaceVert;
    float soundDistance; // distance from particle to sound source in camera space
} vVert;

// Output variable for the color
layout(location = 0) out vec4 fragColor[TD_NUM_COLOR_BUFFERS];


// ---------------------------------------------------------------------------

// picks a color from the sColorRamp gradient using the distance as vertical texture coordinate
// applies alpha using distance and magnitude (shorter distance = higher alpha)
// TODO: distance is not scaled properly ?
vec4 spotlightColor(float distance, float magnitude)
{
	vec4 rampColor = texture(sColorRamp, vec2(0.5, clamp(distance,0.0,1.0)));
    rampColor.a = (1.0-distance) * magnitude;
    return rampColor;
}

// picks a color from the sColorRamp gradient using the distance value ratio to cameras-space Z distance
// creates a sort of sweep along Z-axis as input distance changes
vec4 zDistanceRampColor(float distance)
{
    float rampV = (-vVert.camSpaceVert.z) / (distance*10.0);
    vec4 rampColor = texture(sColorRamp, vec2(0.5, rampV));
    rampColor.a = 1.0 - rampV;
    return rampColor;
}

// ---------------------------------------------------------------------------
void main()
{
	TDCheckDiscard(); // discard unused pixels

    // apply spotlight effect based on sound position (camera space)
    vec4 color = mix(vVert.color, spotlightColor(vVert.soundDistance, clamp(uSound1.w, 0.0, 1.0)), uSpotlightBlend);

    // TODO: not sure this is useful at all
    //vec4 color = mix(vVert.color, zDistanceRampColor(uSound1.w), uSpotlightBlend);

    // texture the point sprite
    vec2 pointUVs = -gl_PointCoord;
    vec4 texture = texture(sSpriteTex, pointUVs);
	fragColor[0] = TDOutputSwizzle(texture * color);
}
