uniform vec3 uBlobPosition;
uniform vec4 uColorMultiplier;
uniform vec4 uColorAdd;
uniform float uRadius;

layout(location = 0) out vec4 outColor;

void main()
{
	// sample the input
	vec4 inPos = texture(sTD2DInputs[0], vUV.st);
	vec4 inColor = texture(sTD2DInputs[1], vUV.st);
	vec4 inNoise = texture(sTD2DInputs[2], vUV.st);

	vec4 pos = inPos;
	vec4 color = inColor;

	// check if point is inside blob radius
	if (length(pos.xyz - uBlobPosition) < (uRadius - inNoise.x)) {
		color *= uColorMultiplier;
		color += uColorAdd;
	}

	outColor = color;
}
