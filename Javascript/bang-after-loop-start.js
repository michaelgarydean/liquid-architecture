inlets = 2;
outlets = 1;

/**
 * left inlet: playing_position
 * right inlet: loop_start
*/
var playing_position;
var loop_start;

var loop_start_has_passed = false;
var clip_has_fired = false;

/**
 * Take input from the inlets
 */
function msg_float( input ) {
	
	// Check if number came from the right-most inlet
	// Update values
	if( inlet == 1 ) {
		loop_start = input;
	} else {
		playing_position = input;
	}
	
	bang_after_loop_start();
}

/**
 * Indicate the state change.
 */
function bang_after_loop_start() {
	
	// Don't calculate if loop start isn't set 
	if ( typeof loop_start == 'undefined' ) {
		return;
	}
	
	// Bang when the playing position passes the loop_start
	if ( playing_position < loop_start ) {
		loop_start_has_passed = false;
	}	
	
	// Only send the bang once.
	if ( loop_start_has_passed == true ) {
		return;
	}	
	
	// Bang when the playing position passes the loop_start
	if ( playing_position > loop_start ) {
		loop_start_has_passed = true;
		outlet(0,"bang");
	}
}