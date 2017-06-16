inlets = 2;
outlets = 2;

//An array of all the clips that have been fired.
var clip_slots_called = new Array();
var num_scenes;

function msg_int(input) {
	if(this.inlet == 1) {
		num_scenes = input;
		return;
	}
	
	clip_slot_index = input;
	
	/**
	 * Check if the queried clip slot has already been called.
	 */
	if(clip_slots_called.indexOf(clip_slot_index) == -1) {
		
		//Add new clip slots to the array
		clip_slots_called.push(clip_slot_index); 
		
		post(clip_slots_called + "\n");
		outlet(0, clip_slot_index);
		
	} else {
		
		//@TODO and num_scenes is defined
		//stop calling clips. All occupied clips slots have been fired.
		if(clip_slots_called.length == num_scenes) {
			clear();
			post(clip_slots_called);
		} else {
			//Query a new clip slot since this one has already been called before.
			outlet(1, "bang");
		}
	}
}

function clear() {
	clip_slots_called = new Array();
}