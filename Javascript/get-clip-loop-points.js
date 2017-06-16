inlets = 1
outlets = 2

function bang() {
	
	/**
 	* Get the LiveObject of the current track
 	*/
	var parent_track = new LiveAPI("this_device canonical_parent");

	/**
 	* Get the LiveObject of the first clip in this track
 	*
 	* @TODO clip slot should be available in interface, for modification.
 	* 
 	* Ids are printed as two arguments: 
 	* ex. id 6 id 23 id 67
 	*/

	var clip_index = 0;
	var clip_path = "this_device canonical_parent clip_slots " + clip_index + " clip";
	var clip = new LiveAPI( clip_path );

	var loop_start = clip.get("loop_start");
	var loop_end = clip.get("loop_end");

	outlet(0,loop_start);
	outlet(1,loop_end);
}