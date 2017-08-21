uniform vec3 uCenter;
uniform vec3 uRadius;

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

	vec3 pos = inPos.xyz;
	vec4 color = inColor;

	// check if point is inside the rectangular volume
	if (insideBox(pos, uCenter, uRadius)) {
		vec3 center = normalize(uCenter);
		//float dist = clamp(distance(normalize(pos), center), 0.0, 1.0);
		float dist = distance(pos, uCenter) / length(uRadius);
		vec4 rampColor = texture(sTD2DInputs[2], vec2(0.5, dist));
		rampColor.a = 1.0 - dist;
		color = rampColor;
	} else {
		color.a = 0.0;
	}

	// // check if point is inside the rectangular volume
	// if ((pos.x > uRectA.x && pos.x < uRectB.x) &&
	// 		(pos.y > uRectA.y && pos.y < uRectB.y) &&
	// 		(pos.z > uRectA.z && pos.z < uRectB.z)) {
	//
	// 		vec3 center = normalize(vec3((uRectA.x + uRectB.x) / 2.0, (uRectA.y + uRectB.y) / 2.0, (uRectA.z + uRectB.z) / 2.0));
	// 		//float maxDistance = distance(uRectA, uRectB);
	// 		float dist = clamp(distance(normalize(pos), normalize(center)), 0.0, 1.0);// / maxDistance;
	//
	// 		vec4 rampColor = texture(sTD2DInputs[2], vec2(0.5, dist));
	// 		rampColor.a = 1.0-dist;
	//
	// 		color = rampColor;
	// } else {
	// 	color.a = 0.0;
	// }

	// check if point is inside blob radius
	// if (length(pos.xyz - uBlobPosition) < (uRadius - inNoise.x)) {
	// 	color *= uColorMultiplier;
	// 	color += uColorAdd;
	// }

	outColor = color;
}
