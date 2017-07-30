// Liquid Architecture
// Fragment Shader
// TOP shader to recombine predator/prey subset positions and extrapolate
// to entire position map by applying noise variance

out vec4 fragColor;

// INPUT SAMPLERS
// sTD2DInputs[0] = initial positions
// sTD2DInputs[1] = prey positions
// sTD2DInputs[2] = predator positions
// sTD2DInputs[3] = noise

void main()
{
    vec4 initialPos = texture(sTD2DInputs[0], vUV.st);
    vec4 noise = texture(sTD2DInputs[3], vUV.st);

    float posBufSize = uTD2DInfos[0].res.z;
    float preyBufSize = uTD2DInfos[1].res.z;
    float predatorBufSize = uTD2DInfos[2].res.z;

    //float predatorPreyRatio = predatorBufSize / preyBufSize;

    vec4 outPos = vec4(0.0);

    // if (vUV.s < predatorPreyRatio && vUV.t < predatorPreyRatio) {
    //     vec4 predatorPos = texture(sTD2DInputs[2], vUV.st / predatorRatio);
    //     outPos = predatorPos + noise * 0.1; // noise
    // } else {
        vec4 preyPos = texture(sTD2DInputs[1], vUV.st);
        outPos = preyPos + noise * 0.1;
    // }

    fragColor = TDOutputSwizzle(outPos);
}
