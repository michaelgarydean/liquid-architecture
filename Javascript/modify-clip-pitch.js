/**
 * @author Michael Dean <myke@ckut.ca>
 * @link https://michaeldean.ca
 * @link https://soundcloud.com/wiklow
 */

inlets = 2;
outlets = 0;

var clip_slot_index;

/**
 * Take input from a live.dial device.
 *
 * @param Int pitch_shift The shift (in semitones) to apply to the clip's pitch. -48...48.
 * @return void
 */
function msg_float(input) {
	
	if(input == 0) {
		clip_slot_index = input;
		return;
	}
	
	//Don't try to change the pitch if the clip_slot_index hasn't been identified
	//@TODO don't try to change pitch of a clip with status of -1 or -2
	if ( typeof clip_slot_index == 'undefined' ) {
		return;
	}
	
	//If float-value input is from another outlet, it must be the pitch_shift
	var pitch_shift = input;
	
	//Set the pitch of the clip located in clip_slot_index
	set_clip_pitch(clip_slot_index, pitch_shift);
}

/**
 * Set the pitch of a clip using it's clip slot index.
 *
 * @param Int clip_slot_index 	The location of the clip to apply the pitch change to.
 * @param Int pitch_shift 		The shift (in semitones) to apply to the clip's pitch. -48...48.
 */
function set_clip_pitch(clip_slot_index, pitch_shift) {
	
	//Create a path to refer to the clip
	var clip_path = "this_device canonical_parent clip_slots " + clip_slot_index + " clip";
	
	//Create a LiveAPI object for the clip
	clip = new LiveAPI(clip_path);
	
	//@TODO if is_audio_clip else return
	
	//Confirm the value is an int (required for the pitch_coarse property)
	pitch_shift = Math.round(pitch_shift);
	
	//Set the clip's pitch property
	clip.set("pitch_coarse", pitch_shift);
}