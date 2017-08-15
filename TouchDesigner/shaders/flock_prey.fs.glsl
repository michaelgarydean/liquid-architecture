// Liquid Architecture
// Flocking Behaviour Fragment Shader - Prey
// TOP shader for applying flocking motion to particle position map

uniform float uDelta;
uniform float uReset;

uniform vec3 bounds;

uniform float multiplier = 50.0;

layout(location = 0) out vec4 outPos;
layout(location = 1) out vec4 outVel;

// INPUT SAMPLERS
// sTD2DInputs[0] = prey positions
// sTD2DInputs[1] = prey velocities
// sTD2DInputs[2] = prey initial positions
// sTD2DInputs[3] = predator positions


void reset()
{
	vec4 initialPos = texture(sTD2DInputs[2], vUV.st);
	outPos = initialPos;
	outVel = vec4(0.0);
}

// PREY

void reactToLanterns( inout vec3 acc, vec3 _myPos )
{
    //float index = invNumLightsHalf;
    //for( float i=0.0; i<numLights; i+=1.0 ) {
        //vec4 LANTERN	= texture( lanternsTex, vec2( index, 0.25 ) );
        vec3 pos		= vec3(0.0);//LANTERN.xyz;
        float radius	= 5.0;//LANTERN.w;
        float minRad	= ( radius + 50.0 ) * ( radius + 50.0 );
        float maxRad	= ( radius + 350.0 ) * ( radius + 350.0 );

        vec3 dirToLantern		= _myPos - pos;
        float distToLantern		= length( dirToLantern );
        float distToLanternSqrd	= distToLantern * distToLantern;

        // IF WITHIN THE ZONE, REACT TO THE LANTERN
        //if( distToLanternSqrd > minRad && distToLanternSqrd < maxRad ) {
            acc -= normalize( dirToLantern ) * ( ( maxRad - minRad ) / distToLanternSqrd ) * 0.01075 * uDelta;
        //}

        // IF TOO CLOSE, MOVE AWAY MORE RAPIDLY
        if( distToLantern < radius * 1.1 ) {
            acc += normalize( dirToLantern );
		}

        //index			+= invNumLights;
    //}
}



void reactToPredators( inout vec3 acc, inout float crowded, vec3 fishPos )
{
    float pInvFboDim = uTD2DInfos[3].res.x;
    int pFboDim = int(uTD2DInfos[3].res.z);

    for( int y=0; y<pFboDim; y++ ) {
        for( int x=0; x<pFboDim; x++ ) {
            vec2 tc					= vec2( float(x), float(y) ) * pInvFboDim + pInvFboDim * 0.5;
            vec3 predatorPos		= texture( sTD2DInputs[3], tc ).rgb * multiplier;
            float predatorZoneRadius	= 90.0 * 90.0;

            vec3 dirToPredator			= fishPos - predatorPos;
            float distToPredator		= length( dirToPredator );
            float distToPredatorSqrd	= distToPredator * distToPredator;

            if( distToPredatorSqrd < predatorZoneRadius ) {
                float per = predatorZoneRadius / ( distToPredatorSqrd + 1.0 );
                crowded += per;
                acc += normalize( dirToPredator ) * per * 0.12 * uDelta;
            }
        }
    }
}

// MAIN

void simulatePrey()
{
	// REALTIME MAC LAPTOP
	float zoneRadius	 = 30.0;
	float zoneRadiusSqrd = zoneRadius * zoneRadius;
	float minThresh		 = 0.44;
	float maxThresh		 = 0.90;
	float maxSpeed		 = 4.1;
	float crowdMulti	 = 0.4;

	// LARGE POPULATION RENDERS
	//	float zoneRadius	 = 15.0;
	//	float zoneRadiusSqrd = zoneRadius * zoneRadius;
	//	float minThresh		 = 0.44;
	//	float maxThresh		 = 0.90;
	//	float maxSpeed		 = 4.1;
	//	float crowdMulti	 = 0.4;

	vec4 vPos = texture( sTD2DInputs[0], vUV.st );
	vec3 myPos = vPos.rgb * multiplier;
	float leadership = vPos.a;

	vec4 vVel = texture( sTD2DInputs[1], vUV.st );
	vec3 myVel = vVel.rgb * multiplier;
	float myCrowd = vVel.a;

	vec3 acc			= vec3( 0.0, 0.0, 0.0 );
	float invFboDim = uTD2DInfos[0].res.x;
	float particleBufSize = uTD2DInfos[0].res.z;
	int fboDim = int(particleBufSize);
	float offset		= invFboDim * 0.5;

	int myX				= int( vUV.s * particleBufSize );
	int myY				= int( vUV.t * particleBufSize );
	float crowded		= 2.0;

	// APPLY THE ATTRACTIVE, ALIGNING, AND REPULSIVE FORCES
	for( int y=0; y<fboDim; y++ ) {
		for( int x=0; x<fboDim; x++ ) {
			if( x == myX && y == myY ) {
					// Avoid comparing my sphere against my sphere
			} else {
				vec2 tc			= vec2( float(x), float(y) ) * invFboDim + offset;
				vec4 pos		= texture( sTD2DInputs[0], tc );
				vec3 dir		= myPos - (pos.xyz * multiplier);

				float dist		= length( dir );
				float distSqrd	= dist * dist;

				vec3 dirNorm	= normalize( dir );

				if( distSqrd < zoneRadiusSqrd ) {
					float percent = distSqrd/zoneRadiusSqrd + 0.0000001;
					crowded += ( 1.0 - percent ) * crowdMulti;

					// IF FISH IS CLOSE, REPEL
					if( percent < minThresh ) {
						float F  = ( minThresh/percent - 1.0 );
						acc		+= dirNorm * F * 0.1 * uDelta * leadership;

							// IF FISH IS IN THE SWEET SPOT, ALIGN
					} else if( percent < maxThresh ) {
						float threshDelta		= maxThresh - minThresh;
						float adjustedPercent	= ( percent - minThresh )/( threshDelta + 0.0000001 );
						float F					= ( 1.0 - ( cos( adjustedPercent * 6.28318 ) * -0.5 + 0.5 ) );

						acc += normalize( texture( sTD2DInputs[1], tc ).xyz * multiplier ) * F * 0.1 * uDelta * leadership;

							// IF FISH IS FAR, BUT WITHIN THE ACCEPTABLE ZONE, ATTRACT
					} else if( dist < zoneRadius ) {

						float threshDelta		= 1.0 - maxThresh;
						float adjustedPercent	= ( percent - maxThresh )/( threshDelta + 0.0000001 );
						float F					= ( 1.0 - ( cos( adjustedPercent * 6.28318 ) * -0.5 + 0.5 ) ) * 0.1 * uDelta * leadership;

						acc -= dirNorm * F;

					}
				}
			}
		}
	}

	reactToLanterns( acc, myPos );

	reactToPredators( acc, crowded, myPos );


	myCrowd -= ( myCrowd - crowded ) * ( 0.1 * uDelta );

	// MODULATE MYCROWD MULTIPLIER AND GRAVITY FOR INTERESTING DERIVATIONS

	myVel += acc * uDelta;
	float newMaxSpeed = maxSpeed + myCrowd * 0.03;			// CROWDING MAKES EM FASTER

	float velLength = length( myVel );						// GET READY TO IMPOSE SPEED LIMIT
	if( velLength > newMaxSpeed ) {							// SPEED LIMIT FOR FAST
		myVel = normalize( myVel ) * newMaxSpeed;
	}


	// MAIN GRAVITY TO MAKE THEM FALL
	//	myVel += vec3( 0.0, -0.0025, 0.0 );

	vec3 tempNewPos		= myPos + myVel * uDelta;		// NEXT POSITION


	// AVOID WALLS
	vec3 roomBounds = bounds;//vec3(350.0, 200.0, 350.0);
	float xPull	= tempNewPos.x/( roomBounds.x );
	float yPull	= tempNewPos.y/( roomBounds.y );
	float zPull	= tempNewPos.z/( roomBounds.z );
	myVel -= vec3( xPull * xPull * xPull * xPull * xPull,
								yPull * yPull * yPull * yPull * yPull,
								zPull * zPull * zPull * zPull * zPull ) * 0.1;

	bool hitWall = false;
	vec3 wallNormal = vec3( 0.0 );
	float myRadius = 4.0;

	if( tempNewPos.y - myRadius < -roomBounds.y ) {
			hitWall = true;
			wallNormal += vec3( 0.0, 1.0, 0.0 );
	} else if( tempNewPos.y + myRadius > roomBounds.y ) {
			hitWall = true;
			wallNormal += vec3( 0.0,-1.0, 0.0 );
	}

	if( tempNewPos.x - myRadius < -roomBounds.x ) {
			hitWall = true;
			wallNormal += vec3( 1.0, 0.0, 0.0 );
	} else if( tempNewPos.x + myRadius > roomBounds.x ) {
			hitWall = true;
			wallNormal += vec3(-1.0, 0.0, 0.0 );
	}

	if( tempNewPos.z - myRadius < -roomBounds.z ) {
			hitWall = true;
			wallNormal += vec3( 0.0, 0.0, 1.0 );
	} else if( tempNewPos.z + myRadius > roomBounds.z ) {
			hitWall = true;
			wallNormal += vec3( 0.0, 0.0,-1.0 );
	}

	// WARNING, THIS MAY BE FAULTY MATH. MIGHT EXPLAIN LOST PARTICLES
	if( hitWall ) {
			vec3 reflect = 2.0 * wallNormal * ( wallNormal * myVel );
			myVel -= reflect * 0.65;
	}

	// update position
	myPos = myPos + ( myVel * ( myCrowd * 0.05 ) * uDelta );

	outPos = vec4(myPos / multiplier, leadership);
	outVel = vec4(myVel / multiplier, myCrowd);
}

// MAIN

void main()
{
	if (uReset < 1.0) {
		simulatePrey();
	} else {
		reset();
	}
}
