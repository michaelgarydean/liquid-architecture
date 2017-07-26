uniform vec4 uForce;
uniform float uDelta;
uniform float uReset;
uniform float uThreshold;

layout(location = 0) out vec4 outPos;
layout(location = 1) out vec4 outVel;


void reset() {
	vec4 initialPos = texture(sTD2DInputs[2], vUV.st);
	outPos = initialPos;
	outVel = vec4(0.0);
}

vec4 applyForce() {
	vec4 inPos = texture(sTD2DInputs[0], vUV.st);
	vec4 inVel = texture(sTD2DInputs[1], vUV.st);
	vec4 noise = texture(sTD2DInputs[3], vUV.st);

	vec3 pos = inPos.rgb;
	float mass = inPos.a;

	vec3 vel = inVel.rgb;
	float age = inVel.a;

	// vec3 forcePos = uForce.xyz;
	// float power = uForce.a;
	//
	// vec3 acc = vec3(0.0);
	// vec3 dirToForce			= forcePos - pos;
	// float distToForce		= length( dirToForce );
	// float distToForceSq		= distToForce * distToForce;

	// acc = ( power * ( dirToForce / distToForceSq ) );

	if (uReset == 0.0) {
		vec3 multiplier = vec3(noise.x, noise.y, noise.z) * 0.05;
		vec3 acc = uForce.xyz * clamp(noise.x, -0.1, 0.1);

		vel = vel + uDelta * acc;
		//vel = vel - damping * vel; // friction/damping
		pos	= pos + uDelta * vel; // symplectic euler position update

		//outPos = vec4(pos, mass);
		outVel = vec4(vel, age);
	} else {
		//pos	= pos + uDelta * vel;
		vel = vec3(0.0);
		outVel = vec4(vel, age);
	}

	return vec4(pos, mass);
}

void main()
{
	vec4 initialPos = texture(sTD2DInputs[2], vUV.st);
	if (uReset < 1.0 && initialPos.y > uThreshold) {
		vec4 forcePos = applyForce();
		outPos = mix(forcePos, initialPos, uReset);
	} else {
		reset();
	}
}
