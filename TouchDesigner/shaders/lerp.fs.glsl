uniform vec4 uFormationStep;

out vec4 fragColor;


void main()
{
	// sample the input
	vec4 onePos = texture(sTD2DInputs[0], vUV.st);
	vec4 twoPos = texture(sTD2DInputs[1], vUV.st);

	// scale each color channel (the XYZ of the vector) separately
	// vec4 outPos = vec4(gridPosition.x + (inPos.x * 0.1), gridPosition.y + (inPos.y * 0.1), gridPosition.z + inPos.z, 1.0);

	vec4 outPos = mix(onePos, twoPos, uFormationStep.x);

	// output the new position
	fragColor = outPos;
}
