// Holds 1.0 / primsPerObject
uniform float uPrimsPerObject;

uniform int uObjectsPerInstance;

uniform sampler2D sPositionMap;
uniform sampler2D sColorMap;

// holds vec4(1.0 / w, 1.0 / h, w, h)
uniform vec4 uMapSize;

in float primIndex;

out Vertex {
	vec4 color;
	vec3 camSpaceVert;
	vec3 camVector;
	vec3 norm;
	//vec3 originalPos;
	// MB - May 25, 2015: Add projSpaceVert
	//vec4 projSpaceVert;

}vVert;

out vec3 originalPos;

void main()
{

	// Instead of using TDDeform, we will do custom instacing
	// here since each instance is actually composed of
	// multiple objects that need individual transforms
	// uPrimsPerObject actually holds it's reciprocal (1.0 / n)
	// which is why we multiply
	int objectId = int(int(primIndex) * uPrimsPerObject);

	int instanceId = gl_InstanceID * uObjectsPerInstance + objectId;

	// The position/color are now stored in a 2D texture with a limited
	// width instead of a large length texture buffer object
	// so we need to get the u/v of the texture based on
	// the bottom left pixel of the texture being instance 0
	vec2 mapCoord;
	int rowIndex = int(floor(instanceId * uMapSize.x));
	mapCoord.s = ((instanceId - (rowIndex * uMapSize.p) + 0.5)) * uMapSize.x;
	mapCoord.t = (rowIndex + 0.5) * uMapSize.y;

	vec3 translate = texture(sPositionMap, mapCoord).xyz;
	originalPos = translate;

	mat4 m = TDInstanceMat(instanceId);
	//m = uTDMat.world * m;
	vec4 worldSpaceVert = uTDMat.world * (vec4(P + translate, 1.0));


	vec4 camSpaceVert = uTDMat.cam * worldSpaceVert;

	// MB - May 25, 2015:
	// Output the projection space vert so we can
	// use them for a lookup
	vec4 projVert = TDCamToProj(camSpaceVert);
	//vVert.projSpaceVert = projVert;
	gl_Position = projVert;

	// This is here to ensure we only execute lighting etc. code
	// when we need it. If picking is active we don't need this, so
	// this entire block of code will be ommited from the compile.
	// The TD_PICKING_ACTIVE define will be set automatically when
	// picking is active.
#ifndef TD_PICKING_ACTIVE

	vec3 camSpaceNorm = uTDMat.camForNormals * TDDeformNorm(N).xyz;
	vVert.norm.stp = camSpaceNorm.stp;
	vVert.camSpaceVert.xyz = camSpaceVert.xyz;
	vVert.color = texture(sColorMap, mapCoord); //TDInstanceColor(instanceId, Cd);
	vec3 camVec = -camSpaceVert.xyz;
	vVert.camVector.stp = camVec.stp;

#else // TD_PICKING_ACTIVE

	// This will automatically write out the nessesarily values
	// for this shader to work with picking.
	// See the documentation if you want to write custom values for picking.
	TDWritePickingValues();

#endif // TD_PICKING_ACTIVE
}
