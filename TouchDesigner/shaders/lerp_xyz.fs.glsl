// Liquid Architecture
// LERP2 - Formation Fragment Shader
// TOP shader for moving paticles into target formation

uniform float uDelta;
uniform float uRunning;
uniform float uStep;

layout(location = 0) out vec4 outPos;


// NOISE/FBM helpers

// mat3 m = mat3( 0.00,  0.80,  0.60,
// 			  -0.80,  0.36, -0.48,
// 			  -0.60, -0.48,  0.64 );
//
//
// float hash( float n )
// {
//     return fract(sin(n)*43758.5453);
// }
//
// float noise( in vec3 x )
// {
//     vec3 p = floor(x);
//     vec3 f = fract(x);
//
//     f = f*f*(3.0-2.0*f);
//     float n = p.x + p.y*57.0 + 113.0*p.z;
//     return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
//                    mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
//                mix(mix( hash(n+113.0), hash(n+114.0),f.x),
//                    mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
// }
//
// float fbm (vec3 p)
// {
// 	float f;
// 	f  = 0.5000*noise( p ); p = m*p*2.02;
// 	f += 0.2500*noise( p ); p = m*p*2.03;
// 	f += 0.1250*noise( p );
// 	return f;
// }

float circularInOut(float t) {
  return t < 0.5
    ? 0.5 * (1.0 - sqrt(1.0 - 4.0 * t * t))
    : 0.5 * (sqrt((3.0 - 2.0 * t) * (2.0 * t - 1.0)) + 1.0);
}

float exponentialInOut(float t) {
  return t == 0.0 || t == 1.0
    ? t
    : t < 0.5
      ? +0.5 * pow(2.0, (20.0 * t) - 10.0)
      : -0.5 * pow(2.0, 10.0 - (t * 20.0)) + 1.0;
}

float cubicInOut(float t) {
  return t < 0.5
    ? 4.0 * t * t * t
    : 0.5 * pow(2.0 * t - 2.0, 3.0) + 1.0;
}

float quadraticInOut(float t) {
  float p = 2.0 * t * t;
  return t < 0.5 ? p : -p + (4.0 * t) - 1.0;
}

float quarticInOut(float t) {
  return t < 0.5
    ? +8.0 * pow(t, 4.0)
    : -8.0 * pow(t - 1.0, 4.0) + 1.0;
}

float qinticInOut(float t) {
  return t < 0.5
    ? +16.0 * pow(t, 5.0)
    : -0.5 * pow(2.0 * t - 2.0, 5.0) + 1.0;
}

float quadraticIn(float t) {
  return t * t;
}

float quadraticOut(float t) {
  return -t * (t - 2.0);
}

// ----
void main()
{
    vec4 startPos = texture(sTD2DInputs[0], vUV.st);

    if (uRunning < 1.0) {
        outPos = startPos;
        return;
    }

    vec4 targetPos = texture(sTD2DInputs[1], vUV.st);
    vec4 pos = vec4(1.0);

    if (uStep < 0.333) {
        // x
        float xstep = uStep / 0.333;
        xstep = quadraticInOut(xstep);
        pos.x = mix(startPos.x, targetPos.x, xstep);
        pos.y = startPos.y;
        pos.z = startPos.z;
    } else if (uStep < 0.666) {
        // z
        float zstep = (uStep - 0.333) / 0.333;
        zstep = quadraticInOut(zstep);
        pos.x = targetPos.x;
        pos.z = mix(startPos.z, targetPos.z, zstep);
        pos.y = startPos.y;
    } else {
        float ystep = (uStep - 0.666) / 0.333;
        ystep = quadraticInOut(ystep);
        pos.x = targetPos.x;
        pos.z = targetPos.z;
        pos.y = mix(startPos.y, targetPos.y, ystep);
    }

    outPos = pos;
}
