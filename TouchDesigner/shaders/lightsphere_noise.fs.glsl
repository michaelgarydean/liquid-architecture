uniform vec3 uRampNearFar;

// each uSoundN vector stores xyz position of the sound + amplitude value
uniform vec4 uSound1;
// audio-reactivity level for the sounds above
uniform float uLevels;
uniform float uDynamicLightShape;

uniform sampler2D sColorRamp;

in Vertex {
	vec4 color;
	vec3 camSpaceVert;
	vec3 camVector;
	vec3 norm;
	vec4 projSpaceVert;
}vVert;

in vec4 soundPos;
in float soundDistance;
in vec4 noise;

uniform float uColorScale;
// Output variable for the color
layout(location = 0) out vec4 fragColor[TD_NUM_COLOR_BUFFERS];


bool insideBox(vec3 point, vec3 center, vec3 radius) {
    return (abs(point.x - center.x) <= radius.x &&
			abs(point.y - center.y) <= radius.y &&
			abs(point.z - center.z) <= radius.z);
}

vec4 applyColorRamp(vec4 color, float level, float size, float amount) {
	vec4 outColor = color;
	if (amount > 0.0) {
		if (uDynamicLightShape < 1.0) {
			// sphere
			vec4 rampColor = texture(sColorRamp, vec2(0.5, level));
			float radius = size + length(noise)*0.1;
			if (level < radius) {
				outColor = vec4(rampColor.rgb, 1.0-(level/radius));//mix(vec4(color.rgb, dist), vec4(rampColor.rgb, rampColor.a * dist), uSound1.w);
			} else {
				//outColor.a += 1.0 - amount;
			}
		} else {
			// box
		}
	}
	return outColor;
}


void main()
{
	// This allows things such as order independent transparency
	// and Dual-Paraboloid rendering to work properly
	TDCheckDiscard();

	// MB - May 25, 2015:
	// Look at the vertex z value and rescale to
	// uRampNearFar, where 0 is at near and 1 is at far
	// z is along the -Z axis to negate it to start
	//float rampV = (-vVert.camSpaceVert.z - uRampNearFar.x) / (uRampNearFar.y - uRampNearFar.z);
	// sample the ramp using the V value which will be 0 at the bottom
	// of the image and 1 at the top
	//vec4 rampColor = texture(sColorRamp, vec2(0.5, rampV));

	// base color from model color map
	vec4 baseColor = vVert.color.rgba; // vec4(vVert.camVector, 1.0); // <-- to debug camera space values
	baseColor.a = 1.0 - uLevels;//length(uLevels);

	vec4 color = baseColor;

	color = applyColorRamp(color, soundDistance, uSound1.w, uLevels);

	fragColor[0].rgba = color;

	// TD_NUM_COLOR_BUFFERS will be set to the number of color buffers
	// active in the render. By default we want to output zero to every
	// buffer except the first one.
	for (int i = 1; i < TD_NUM_COLOR_BUFFERS; i++)
	{
		fragColor[i] = vec4(0.0);
	}
}
