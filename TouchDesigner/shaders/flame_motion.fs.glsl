// Liquid Architecture
// Flame Motion Fragment Shader
// TOP shader for moving paticles using Fractal Brownian Motion
// Adapted from "Evil Space Flame"

uniform float uTime;
uniform float uReset;

// PARAMS
// x = turbulence
// y = life
// z = speed
uniform vec4 uParams1 = vec4(0.264, 1.0, 0.5, 0.0);
float turbulence = uParams1.x;
float respawn = uParams1.y;
float speed = uParams1.z;

// INPUT SAMPLERS
// 0 = init position
// 1 = noise position

// OUTPUT BUFFERS
// 0 = simulated position
// 1 = output position
layout(location = 0) out vec4 simPos;
//layout(location = 1) out vec4 outPos;

mat3 m = mat3( 0.00,  0.80,  0.60,
			  -0.80,  0.36, -0.48,
			  -0.60, -0.48,  0.64 );


float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0 + 113.0*p.z;
    return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                   mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
}


float fbm (vec3 p)
{
	float f;
	f  = 0.5000*noise( p ); p = m*p*2.02;
	f += 0.2500*noise( p ); p = m*p*2.03;
	f += 0.1250*noise( p );
	return f;
}

void main() {
    vec2 vTexcoord = vUV.st;
    vec4 initialPos = texture(sTD2DInputs[0], vTexcoord);
    vec4 pos = texture(sTD2DInputs[1], vTexcoord);

    if (uReset == 0.0) {
        // run simulation
        vec2 uv = vTexcoord * 0.00942 * uTime;
    	vec3 ut = vec3(uv, uTime*0.4172);
    	vec3 uu = vec3(0,0, uTime*0.9272);

    	float sc = fbm(pos.xzy + uu) * turbulence * uTime;

        // position alpha = particle age
    	pos.a += fbm((pos.xyz + uu) * 0.3) * 0.01 * (respawn + 0.001);

        // noise vector
    	vec3 nv = vec3(
        				fbm(sc*pos.zxy + ut),
        				fbm(sc*pos.xyz + ut),
        				fbm(sc*pos.yzx + ut) );

        //if (uTime > 0.25) {
    	       nv -= vec3(0.5*min(uTime, 1.0));
        //}

    	if (pos.a>=1) {
            // respawn
    		pos.xyz = initialPos.rgb;
    		pos.a -= 1;
    	} else {
            // apply noise vector
            float speed = uParams1.z;
    		nv *= 0.28 * (1.2-pos.a*0.5);
    		nv.y += 0.1 * pow(pos.a,2.95);

            pos.xyz += nv * speed;
    	}

        simPos = pos;
        //outPos = pos;
    } else if (uReset < 1.0) {
        // transition to stop -- mix last simulated position and initial
        simPos = pos;
        //outPos = pos;//mix(pos, initialPos, uReset);
    } else {
        // simulation stopped -- initial positions
        simPos = initialPos;
        //outPos = initialPos;
    }
}
