// Liquid Architecture
// Flock Chasing Fragment Shader
// TOP shader for making non-flocked particles chase the flock

// INPUTS
uniform float uReset;
uniform float uDelta;

// SAMPLERS
// INPUT SAMPLERS
// sTD2DInputs[0] = initial positions
// sTD2DInputs[1] = positions
// sTD2DInputs[2] = target positions
// sTD2DInputs[3] = target velocities
// sTD2DInputs[4] = noise

// OUTPUTS
layout(location = 0) out vec4 outPos;
layout(location = 1) out vec4 outVel;


void reset() {
	vec4 initialPos = texture(sTD2DInputs[2], vUV.st);
	outPos = initialPos;
	outVel = vec4(0.0);
}

void main()
{
    vec4 initialPos = texture(sTD2DInputs[0], vUV.st);
    vec4 pos = texture(sTD2DInputs[1], vUV.st);

    if (uReset == 0.0) {
        // run simulation
        vec3 noise = texture(sTD2DInputs[4], vUV.st).rgb * 1.0;
        //vec3 vel = texture(sTD2DInputs[2], vUV.st).rgb;
        vec3 targetPos = texture(sTD2DInputs[2], vUV.st).rgb * noise;
        vec3 targetVel = texture(sTD2DInputs[3], vUV.st).rgb * noise;

        outVel = vec4(normalize(targetPos - pos.rgb), 1.0);//(vec4(targetVel, 1.0) / distance(pos.rgb, targetPos)) * 10.0;//vec4(normalize(targetPos - pos.rgb), 1.0);// * targetVel, 1.0);
		outPos = vec4(targetPos, 1.0);//pos + uDelta * outVel; // symplectic euler position update
    } else if (uReset < 1.0) {
        // transitioning out -- mix last simulated position and initial
        outVel = vec4(0.0);
        outPos = mix(pos, initialPos, uReset);
    } else {
        // stopped -- initial positions
        outVel = vec4(0.0);
        outPos = initialPos;
    }
}
