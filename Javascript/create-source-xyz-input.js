/**
 *
 * @author Michael Dean <myke@ckut.ca>
 */

/**
 * ==================================
 * Object attributes
 * ==================================
 */

//Declare number of inlets and outlets
inlets = 1;
outlets = 0;

//Store references to the created abstraction instances(maximum of 128 possible)
var abstractions = new Array(128);

//Initialize number of sources that exists
var num_sources = 0;

//The MaxObjs to connect each abstraction instance to.
var input_object;
var output_object;

/**
 * ==================================
 * Input functions
 * ==================================
 */

/**
 * Set the number of sound sources for creating the MaxObjs.
 *
 * @param Int num_sources	The number of sound sources.
 * @return void
 */
function msg_int(requested_sources) {

	//Remove envelope followers created during past request (if any request exists)
	if(num_sources) {
		destroy_existing_abstraction_instances(num_sources);
	}
		
	//Don't create sources if none are requested.
	if(requested_sources <= 0) {
		return;
	}
	
	//Limit the total number of envelope followers that can be requested
	if(requested_sources > 128) {
		requested_sources = 128;
	}
	
	//Update num_sources to the new number requested by object input;
	num_sources = requested_sources;
	
	//The audio input device to envelope follow (an [adc~] object)
	//@TODO get the object's scripting name through argument on this js object
	input_object = this.patcher.getnamed("audio-input");

	/**
	 * Create instances of the abstraction for each source, if any have been requested, and connect them
	 * to the input object.
	 */
	if(requested_sources) {
		create_abstractions_for_sources(input_object,num_sources);
	}
}

/**
 * Destroy any existing objects previously created by the patch from last request.
 * At this point, num_sources hasn't been updated, so it's equal to whatever was set
 * from the last request
 *
 * @param Int num_sources	The number of sources requested during the previous request.
 * @return void
 */
function destroy_existing_abstraction_instances(num_sources) {
	
	/** 
	 * Since we declared the maximum number of envelope followers by pre-sizing the array, 
	 * just remove the number of sources previously requested. Don't loop the whole arry.
	 */
	for(var i=0; i<num_sources; i++) {
		this.patcher.remove(abstractions[i]);
	}
}

/**
 * Create a new instance of the abstraction for each of the requested sources
 *
 * @param Int num_sources	The number of sources to create abstractions for
 */
function create_abstractions_for_sources(input_object, num_sources) {
	
	for(var source=0; source<num_sources; source++) {
		
		//Keep a reference of the abstraction so it can be removed later if neccessary
		abstractions[source] = create_abstraction_instance(source);
	
		//Connect the new envelope follower to the adc~ (which uses the script name "audio-input")
		this.patcher.connect(input_object, source*2, abstractions[source], 0);
	}
}

/**
 * Create an abstraction for a specific sound source.
 *
 * @param Int source					The index of the sound source for which the abstraction is being created.
 * @return MaxObj abstraction			The newly created max object (the abstraction)
 */
function create_abstraction_instance(source) {
	
	/**
	 * Create a new instance of the abstraction for the abstraction using the current source as an argument
	 * The argument is used in the abstraction to properly set up the OSC message and tag it.
	 */
	var abstraction_filename= "source-xyz";
	
	//Calculate coordinates for new object
	//@TODO Get position of input object and put objects just a bit below it
	var position_x = 300+source*150;
	var position_y = 450+source;
	
	//Create MaxObjs
	var abstraction = this.patcher.newdefault(
		position_x, 
		position_y, 
		abstraction_filename, 
		source+1
	);
	
	return abstraction;
}