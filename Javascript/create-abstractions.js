/**
 *
 * @author Michael Dean <myke@ckut.ca>
 */

/**
 * ==================================
 * Object definitions
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
var input_connections;
var output_connections;

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
	//@TODO Store the list of objects to get connected
	//input_connection = this.patcher.getnamed("trigger-input");
	//output_connection = this.patcher.getnamed("output-router");

	/**
	 * Create instances of the abstraction for each source, if any have been requested, and connect them
	 * to the input object.
	 */
	if(requested_sources) {
		create_abstractions_for_sources(num_sources);
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
function create_abstractions_for_sources(num_sources) {
	
	for(var source=0; source<num_sources; source++) {
		
		//Keep a reference of the abstraction so it can be removed later if neccessary
		abstractions[source] = create_abstraction_instance(source);
		
		//Connect the new abstraction
		connect_abstraction_to_scripted_objects(abstractions[source]);
	}
}

/**
 * Make connections between the abstractions and scripted objects in the patch
 *
 * @param MaxObj abstraction	The abstraction to connect the scripted objects to.
 */
function connect_abstraction_to_scripted_objects(abstraction) {
	var input_object;
	var output_object;
	var i;
	
	if(input_connections == undefined || output_connections == undefined) {
		post(
			"Input or output objects not defined. Define objects by scripting "
			+ "names using set_input_objects and set_output_objects"
		);
		return;
	}

	//Make connections between the objects inlets and the specified objects
	for(i=0; i < input_connections.length; i++) {
		input_object = this.patcher.getnamed(input_connections[i]);
		this.patcher.connect(input_object, 0, abstraction, i);
	}

	//Make connections between the objects outlets and the specified objects
	for(i=0; i < output_connections.length; i++) {
		output_object = this.patcher.getnamed(output_connections[i]);
		this.patcher.connect(abstraction, i, output_object, 0);
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
	var abstraction_filename = get_abstraction_filename();
	
	if(abstraction_filename == null) {
		return;
	}
	
	//Calculate coordinates for new object
	//@TODO Get position of input object and put objects just a bit below it
	var position_x = 100+source*180;
	var position_y = 200+source;
	
	//Create MaxObjs
	var abstraction = this.patcher.newdefault(
		position_x, 
		position_y, 
		abstraction_filename, 
		source+1
	);
	
	return abstraction;
}

/**
 * Define the filename of the abstraction instances to be created
 *
 * @param Int source					The index of the sound source for which the abstraction is being created.
 * @return MaxObj abstraction			The newly created max object (the abstraction)
 */
function get_abstraction_filename() {
	
	//If no argument has been defined in the js object, update the Max console.
	if(jsarguments[1] == undefined) {
		post("No abstraction file is specified"); //@TODO if no abstraction, return from all functions
		return null;
		
	//Otherwise return the abstraction filename.
	} else {
		return jsarguments[1];
	}
}

/**
 * Set the objects to connect the abstractions' inlets.
 *
 * Objects are connected using the index of each object as the inlet index.
 * ex. set_input_objects object1 object2
 * This means object1's outlet 0 will be connected to each abstraction's inlet 0,
 * and object2's outlet 0 will be connected to each abstraction's inlet 1.
 *
 * @param list scripting_names			A list of scripting names of the objects to be connected to the abstraction's inlets
 */
function set_input_objects(scripting_names) {
	input_connections = arrayfromargs(arguments);
}

/**
 * Set the objects to connect the abstractions' outlets.
 *
 * @see set_input_objects()
 * @param list scripting_names			A list of scripting names of the objects to be connected to the abstraction's inlets
 */
function set_output_objects(scripting_names) {
	output_connections = arrayfromargs(arguments);
}