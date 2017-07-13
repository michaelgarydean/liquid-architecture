// Liquid Architecture
// Particle Sprite Rendering Vertex Shader
// MAT shader for particle sprites with positional audio data

// inputs
uniform sampler2D sPositionMap;
//uniform sampler2D sNormalMap;
uniform sampler2D sColorMap; // particle base colors

uniform vec3 uResolution;
uniform float uParticleSize;
uniform vec4 uSound1; // audio position (xyz) and value (w)

// outputs
out Vertex {
	vec4 color;
	vec3 camSpaceVert;
	vec3 camVector;
	vec3 norm;
} vVert;

out float soundDistance;

// ---------------------------------------------------------------------------

float distanceToPoint(vec3 point, vec4 fromPoint) {
	vec3 pos = point;
	pos.z = pos.z - 5.0; // HACK: why?
	vec4 pointInWorldSpace = normalize(uTDMat.world * vec4(pos, 1.0));
	//vec4 soundInCameraSpace = normalize(uTDMat.cam * soundInWorldSpace);
	return distance(normalize(fromPoint), pointInWorldSpace);
}

// ---------------------------------------------------------------------------
void main()
{
	float id = gl_VertexID;

    int rowIndex = int(floor(id / uResolution.x));
	float u = ((id - (rowIndex * uResolution.x) + 0.5)) / uResolution.x;
	float v = (rowIndex + 0.5) / uResolution.y;

	vec2 mapCoord = vec2(u,v);
	vec4 position = texture(sPositionMap, mapCoord);

	vec4 worldSpaceVert = TDDeform(position);
	vec4 camSpaceVert = uTDMat.cam * worldSpaceVert;
	gl_Position = TDWorldToProj(worldSpaceVert);

    // particle size
	gl_PointSize = uParticleSize;

    // This is here to ensure we only execute lighting etc. code
    // when we need it. If picking is active we don't need this, so
    // this entire block of code will be ommited from the compile.
    // The TD_PICKING_ACTIVE define will be set automatically when
    // picking is active.
#ifndef TD_PICKING_ACTIVE

    vec3 camSpaceNorm = uTDMat.camForNormals * TDDeformNorm(N).xyz;
    vVert.norm.stp = camSpaceNorm.stp;
    vVert.camSpaceVert.xyz = camSpaceVert.xyz;
    vVert.color = texture(sColorMap, mapCoord);
    vec3 camVec = -camSpaceVert.xyz;
    vVert.camVector.stp = camVec.stp;

    // distance from particle to sound source in camera space
    soundDistance = distanceToPoint(uSound1.xyz, camSpaceVert);

#else // TD_PICKING_ACTIVE

    // This will automatically write out the nessesarily values
    // for this shader to work with picking.
    // See the documentation if you want to write custom values for picking.
    TDWritePickingValues();

#endif // TD_PICKING_ACTIVE
}
