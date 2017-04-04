/**
 * Create envelope followers for each sound source.
 *
 * Automatically duplicate the neccessary objects to do envelope
 * following for each sound source. Make the connections between
 * objects as neccessary.
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
function msg_int(num_sources) {
}

/**
 * Create an envelope follower abstraction for a specific sound source.
 */
function create_envelope_follower() {
	//this.patcher.message("script", "newobject", "sat-envelope-follower");
	this.patcher.newdefault(300, 300, "sat-envelope-follower");
	this.patcher.getnamed("patch1");
}