// Holds 1.0 / primsPerObject
uniform float uPrimsPerObject;

uniform int uObjectsPerInstance;

uniform sampler2D sPositionMap;
uniform sampler2D sColorMap;

// holds vec4(1.0 / w, 1.0 / h, w, h)
uniform vec4 uMapSize;

// each uSoundN vector stores xyz position of the sound + amplitude value
uniform vec4 uSound1;
uniform vec4 uSound2;
uniform vec4 uSound3;
uniform vec4 uSound4;
// audio-reactivity level for the sounds above
uniform vec4 uLevels;

in float primIndex;

out Vertex {
	vec4 color;
	vec3 camSpaceVert;
	vec3 camVector;
	vec3 norm;
	vec4 projSpaceVert;
}vVert;

out vec4 soundDistance;

float distanceToPoint(vec3 point, vec4 fromPoint) {
	vec3 pos = point;
	pos.z = pos.z - 5.0; // HACK: why?
	vec4 pointInWorldSpace = normalize(uTDMat.world * vec4(pos, 1.0));
	//vec4 soundInCameraSpace = normalize(uTDMat.cam * soundInWorldSpace);
	return distance(normalize(fromPoint), pointInWorldSpace);
}

void main()
{

  // P is the position of the current vertex
  // TDDeform() will return the deformed P position, in world space.
  // Transform it from world space to projection space so it can be rasterized

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

	vec4 worldSpaceVert = uTDMat.world * (vec4(P + translate, 1.0));

	vec4 camSpaceVert = uTDMat.cam * worldSpaceVert;

	// MB - May 25, 2015:
	// Output the projection space vert so we can
	// use them for a lookup
	vec4 projVert = TDCamToProj(camSpaceVert);
	vVert.projSpaceVert = worldSpaceVert;
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
	vVert.color = texture(sColorMap, mapCoord);
	vec3 camVec = -camSpaceVert.xyz;
	vVert.camVector.stp = camVec.stp;

#else // TD_PICKING_ACTIVE

	// This will automatically write out the nessesarily values
	// for this shader to work with picking.
	// See the documentation if you want to write custom values for picking.
	TDWritePickingValues();

#endif // TD_PICKING_ACTIVE

	// calculate distances to sounds
	if (uLevels.x > 0.0) {
		soundDistance.x = distanceToPoint(uSound1.xyz, camSpaceVert);
	}
	// if (uLevels.y > 0.0) {
	// 	soundDistance.y = distanceToPoint(uSound2.xyz, camSpaceVert);
	// }
	// if (uLevels.z > 0.0) {
	// 	soundDistance.z = distanceToPoint(uSound3.xyz, camSpaceVert);
	// }
	// if (uLevels.w > 0.0) {
	// 	soundDistance.w = distanceToPoint(uSound4.xyz, camSpaceVert);
	// }
}
