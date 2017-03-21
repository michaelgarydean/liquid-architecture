/**
 * Message Repeater
 *
 * Repeat an incoming message a specific number of times with a delay between each repeat.
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
outlets = 1;

//Declare number of times to repeat the MIDI message
var n_repeats = 1;

//Amount of time (in ms) to delay repeated messages
var delay_time = 300;


/**
 * ==================================
 * Input functions
 * ==================================
 */

/**
 * Take MIDI pitch and velocity pair and process it.
 *
 * @see https://docs.cycling74.com/max7/vignettes/jstaskobject
 *  
 * @TODO Apply this function for any type of message, not just MIDI.
 *
 * @param Array arguments		Any list sent to the object that is not caught by the setter functions (see below).
 */
function list() {
	
	//If it's not a pair of values, don't process the function
	if(arguments.length > 2) {
		return;
	}
	
	//Store message in an array
	input_message = arrayfromargs( arguments );
	
	//Output the message and repeat output over a time interval.
	repeater = new Task( output_message, this, input_message );
	repeater.interval = delay_time;
	repeater.repeat( n_repeats + 1 );
}

/**
 * Outputs an incoming message.
 *
 * @param Array input_message		The message to output.
 */
function output_message( input_message ) {
	outlet(0, input_message);
}

/**
 * ==================================
 * Setter functions
 * ==================================
 */

/**
 * Allow user to define the number of times to repeat the message.
 *
 * @param Int n_repeats		The number of times an incoming message will be repeated.
 */
function set_num_repeats( repeats ) {
	n_repeats = repeats;
}

/**
 * Allow user to define the number of times to repeat the message.
 *
 * @param Int time_in_ms		The number of milliseconds to delay each repeated message.
 */
function set_delay_time( time_in_ms ) {
	
	//Force number to be an 'integer'
	delay_time = Math.round( time_in_ms );
}