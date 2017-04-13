uniform vec4 uAmbientColor;
uniform vec4 uDiffuseColor;
uniform vec3 uSpecularColor;
uniform float uShininess;
uniform float uShadowStrength;
uniform vec3 uShadowColor;

uniform vec3 uRampNearFar;

uniform sampler2D sColorRamp;

in Vertex {
	vec4 color;
	vec3 camSpaceVert;
	vec3 camVector;
	vec3 norm;
	// MB - May 25, 2015: Add projSpaceVert
	//vec4 projSpaceVert;
}vVert;

in vec3 originalPos;

uniform float uColorScale;
// Output variable for the color
layout(location = 0) out vec4 fragColor[TD_NUM_COLOR_BUFFERS];
void main()
{
	// This allows things such as order independent transparency
	// and Dual-Paraboloid rendering to work properly
	TDCheckDiscard();

	// MB - May 25, 2015:
	// Look at the vertex z value and rescale to
	// uRampNearFar, where 0 is at near and 1 is at far
	// z is along the -Z axis to negate it to start
	float rampV = (-vVert.camSpaceVert.z - uRampNearFar.x) / (uRampNearFar.z - uRampNearFar.x);
	//float rampV = (-vVert.camSpaceVert.z - uRampNearFar.x) / (uRampNearFar.y - uRampNearFar.z);
	//float rampV = (-originalPos.y/uRampNearFar.z - uRampNearFar.x) / (uRampNearFar.y - uRampNearFar.x);
	// sample the ramp using the V value which will be 0 at the bottom
	// of the image and 1 at the top
	vec4 rampColor = texture(sColorRamp, vec2(0.5, rampV));

	float distance = length(vVert.camSpaceVert);

	fragColor[0].rgba = vVert.color * rampColor * vec4(vec3(uColorScale), rampV);
	//fragColor[0].a = 0.25;
	//fragColor[0] = vec4(1.0);

	// TD_NUM_COLOR_BUFFERS will be set to the number of color buffers
	// active in the render. By default we want to output zero to every
	// buffer except the first one.
	for (int i = 1; i < TD_NUM_COLOR_BUFFERS; i++)
	{
		fragColor[i] = vec4(0.0);
	}
}
