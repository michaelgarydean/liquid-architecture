inlets = 2
outlets = 0

//Initialize global variables
var loop_length = 1;
var clip_index = 0;
var clip;

/**
 * Process integer messages.
 * 
 * inlet 1: The index of the clip to loop.
 * inlet 2: Set length of loop (in bars).
 */
function msg_int(input) {
	
	if(inlet == 0) {
		
	/**
	 * Playing_slot_index property from clip_slot:
	 * -2 = track stop slot fired in session view
	 * -1 = arranger recording with no session clip playing.
	 */		
		if(input>=0) {
			clip_index = input;
		}

	//Loop length set by user (assumed as bars)
	} else if(inlet == 1) {
		loop_length = input;
	}
}

/**
 * Trigger the clip operations.
 */
function bang() {	
	set_loop_bounds();
}

/**
 * Set the bounds of the clip's loop.
 */
function set_loop_bounds() {
	
	//Get the LiveObject of the clip
	var clip_path = "this_device canonical_parent clip_slots " + clip_index + " clip";
	clip = new LiveAPI(clip_path);
	
	//Get the clip's loop_end
	var loop_end = clip.get("loop_end");
	
	//Get the number of beats per bar
	var live_set = new LiveAPI("live_set");
	loop_length_in_beats = loop_length*live_set.get("signature_numerator");
	
	//Set the loop_start, start_time in beats
	var loop_start = loop_end - loop_length_in_beats;
	clip.set("start_marker", loop_start);
	clip.set("loop_start", loop_start);

	//Set the loop length
	clip.set("length", loop_length);
}