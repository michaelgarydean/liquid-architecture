// Liquid Architecture
// Lines Rendering Vertex Shader
// MAT shader for lines

// inputs
uniform sampler2D sPositionMap;
uniform sampler2D sHeightMap;
uniform sampler2D sColorMap; // particle base colors
uniform sampler2D sColorRamp; // gradient for sound based coloring
uniform vec3 uResolution;
uniform vec4 uSound1; // audio position (xyz) and value (w)

// outputs
out Vertex {
	vec4 color;
	vec3 camSpaceVert;
	vec3 camVector;
	vec3 norm;
    float soundDistance;
} vVert;

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
    float id = gl_InstanceID;

    int rowIndex = int(floor(id / uResolution.x));
    float u = ((id - (rowIndex * uResolution.x) + 0.5)) / uResolution.x;
    float v = (rowIndex + 0.5) / uResolution.y;
    vec2 mapCoord = vec2(u,v);
	vec4 position = texture(sPositionMap, mapCoord);

    vec4 worldSpaceVert = TDDeform(position);
    vec4 camSpaceVert = uTDMat.cam * worldSpaceVert;
    vec3 camSpaceNorm = uTDMat.camForNormals * TDDeformNorm(N).xyz;
    vec3 camVec = -camSpaceVert.xyz;

    // outputs for frag shader
    vVert.norm.stp = camSpaceNorm.stp;
    vVert.camSpaceVert.xyz = camSpaceVert.xyz;
    vVert.camVector.stp = camVec.stp;
    vVert.color = texture(sColorMap, mapCoord);

    // distance from particle to sound source in camera space
    vVert.soundDistance = distanceToPoint(uSound1.xyz, camSpaceVert);

    // offset for second line vertex
    float lineHeight = 0.0;
    vec4 height = texture(sHeightMap, mapCoord);
    if (mod(gl_VertexID,2) == 1 && height.x > 0.25) {
        lineHeight = height.y;
    }
    worldSpaceVert.y -= lineHeight; // lines extending in world space
    vec4 projSpaceVert = TDWorldToProj(worldSpaceVert);
    //projSpaceVert.y -= lineHeight; // lines extending in projection space

	gl_Position = projSpaceVert;
}
