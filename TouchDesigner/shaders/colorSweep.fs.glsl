uniform float uDistance;
uniform float uAlphaScale;
uniform float uColorScale;

layout(location = 0) out vec4 outColor;

bool insideBox(vec3 point, vec3 center, vec3 radius) {
    return (abs(point.x - center.x) <= radius.x &&
				abs(point.y - center.y) <= radius.y &&
				abs(point.z - center.z) <= radius.z);
}

void main()
{
	// sample the input
	vec4 inPos = texture(sTD2DInputs[0], vUV.st);
	vec4 inColor = texture(sTD2DInputs[1], vUV.st);

	float rampV = inPos.y / uDistance;
    vec4 rampColor = texture(sTD2DInputs[2], vec2(0.5, rampV));
    vec4 color = inColor * uColorScale * rampColor;
    color.a = rampV * uAlphaScale;
	outColor = color;
}
