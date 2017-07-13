// uniform vec4 uAmbientColor;
// uniform vec4 uDiffuseColor;
// uniform vec3 uSpecularColor;
// uniform float uShininess;
// uniform float uShadowStrength;
// uniform vec3 uShadowColor;

in Vertex {
	vec4 color;
	vec3 camSpaceVert;
	vec3 camVector;
	vec3 norm;
} vVert;

// Output variable for the color
layout(location = 0) out vec4 fragColor[TD_NUM_COLOR_BUFFERS];


// ---------------------------------------------------------------------------
void main()
{
	TDCheckOrderIndTrans();
	fragColor[0] = vVert.color;
}
