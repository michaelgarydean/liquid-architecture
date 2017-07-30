// Liquid Architecture
// Flow Field Fragment Shader
// TOP shader for moving paticles using noise/chops
// Adapted from "Particle Flow Fields"

uniform vec3 resolution;
uniform vec4 colz;
uniform vec4 trigger;
uniform vec4 centre;

// x = reset
// y = speed
// z = curl
// w = turbulence
uniform vec4 uParams1 = vec4(0.0, 0.1, 0.5, 1.0);
uniform float uReset = 0.0;

// OUTPUTS
layout(location=0) out vec4 outPos;
layout(location=1) out vec4 outNorm;
layout(location=2) out vec4 outColor;
layout(location=3) out vec4 finalPos;

////////////////////////////////////////////////////

vec2 res = vec2(uTD2DInfos[1].res.z, uTD2DInfos[1].res.w);
vec2 increment = vec2(uTD2DInfos[1].res.x, uTD2DInfos[1].res.y);


/////////////////////////////////////////////////////
// important bit! Play with this shiz
float speed = uParams1.x * 0.1;

//this increases the frequency of the curling effect.
float tmult = uParams1.y * 6.0;

//this increases the turbulence effect
float turbulencemult = uParams1.z * 2.0;
////////////////////////////////////////////////////

void main()
{
    if (uReset == 0.0) {
        // run simulation
        vec3 position, normals, color;
    	if(vUV.t > 1-increment.y )
    	{
    		//get the incoming data
    		position = texture(sTD2DInputs[4],vec2(vUV.s,0.0)).rgb; //lookup our position
    		normals = texture(sTD2DInputs[6],vec2(vUV.s,0.0)).rgb;
    		color = clamp(colz.rgb, 0.3,1.0) /1.0  + (vec3(1,1,0) * trigger.x /1);
    	}
    	else
    	{
    		//everything else pretty much looks up the color buffers.
    		double offx = 1 + vUV.s;
    		double offy = increment.y + vUV.t;
            position = texture(sTD2DInputs[1],vec2(offx,offy)).rgb;
            normals = texture(sTD2DInputs[2],vec2(offx,offy)).rgb;
            color = texture(sTD2DInputs[5],vec2(offx,offy)).rgb;

    		// this adds a turning force to our particle path
    		vec3 turn =  vec3(cos(position.y * tmult), sin(position.z * tmult), sin(position.x * tmult));

    		//texcoords for the incoming noise texture, based on particle position
    		float lu = -1 * (float(position.r >0) * -1) * position.r;
    		float lv = -1 * (float(position.b >0) * -1) * position.b;
    		float lz = -1 * (float(position.g >0) * -1) * position.g;
    		vec2 texCoord1 = vec2(mod(lu,1), mod(lv,1));
    		vec2 texCoord2 = vec2(mod(lz,1), mod(lu,1));

    		//now we use the noise map to modify our particles path. r=x, g=y, b=z.
    		vec3 velocity = texture(sTD2DInputs[0], texCoord1 ).rgb * turbulencemult + turn ;

    		velocity += texture(sTD2DInputs[3], texCoord2 ).rgb + (normals/ 2) ;

    		position += normalize(velocity)* speed * clamp(trigger.x * 4, 0.7,4.0);
    		normals = normalize( normals +((velocity - 0.5) / 3));
    		color -= increment.x;
    	}

    	outPos = vec4(position.rgb,1);
    	outNorm = vec4(normals,1);
    	outColor = vec4(color,1);
        finalPos = outPos;
    } else if (uReset < 1.0) {
        // transitioning out -- mix last simulated position and initial
        outNorm = texture(sTD2DInputs[2], vUV.st);
        outColor = texture(sTD2DInputs[5], vUV.st);
        vec4 lastPos = texture(sTD2DInputs[1], vUV.st);
        vec4 initialPos = texture(sTD2DInputs[7], vUV.st);
        outPos = lastPos;
        finalPos = mix(lastPos, initialPos, uReset);
    } else {
        // stopped -- initial positions
        outNorm = texture(sTD2DInputs[6], vUV.st);
        outPos = texture(sTD2DInputs[7], vUV.st);
        outColor = texture(sTD2DInputs[5], vUV.st);
        finalPos = outPos;
    }

}
