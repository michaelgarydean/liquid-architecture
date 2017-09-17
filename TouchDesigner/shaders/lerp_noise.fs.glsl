// Liquid Architecture
// LERP - Formation Fragment Shader
// TOP shader for moving paticles into target formation

#define M_PI 3.1415926535897932384626433832795

uniform float uDelta;
uniform float uRunning;
uniform float uStep;
uniform float uNoiseMultiplier = 10.0;
uniform float uEaseFactor = 0.5;

layout(location = 0) out vec4 outPos;



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


// ----
void main()
{
    vec4 startPos = texture(sTD2DInputs[0], vUV.st);
    vec4 targetPos = texture(sTD2DInputs[1], vUV.st);
    vec4 pos = texture(sTD2DInputs[2], vUV.st);

    if (uRunning < 1.0) {
        outPos = startPos;
        return;
    }

    vec4 noise = texture(sTD2DInputs[3], vUV.st) * uNoiseMultiplier;
    noise.a = 0.0;

    float pixelStep = pow(uStep, texture(sTDNoiseMap, vUV.st).r + uEaseFactor);
    float step = cubicInOut(pixelStep);

    //step = pow(step, noise.x + 2.0);

    pos = mix(startPos, targetPos, step);

    // triangle function --
    //float noiseStep = 2.0 * step;
    //if (step > 0.5) {
    //    noiseStep = 2.0 - 2.0 * step;
    //}
    float noiseStep = sin(M_PI * step);

    pos += mix(vec4(0.0), noise, noiseStep);

    outPos = pos;
}
