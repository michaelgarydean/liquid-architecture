/**
 * @author Michael Dean <myke@ckut.ca>
 * @link https://soundcloud.com/wiklow
 */

/**
 * Inlet is provided for the live.thisdevice object.
 */
inlets = 1
outlets = 1

/**
 * Trigger the clip operations.
 */
function bang() {	
	get_playing_slot_index();
}

/**
 * Observe the playing_slot_index property of the track this device is placed on.
 */
function get_playing_slot_index() {
	
	//Create object to observe a property
	var this_track = new LiveAPI(observe_property);
	
	//Get the LiveObject of the track this device is placed on
	this_track.path = "this_device canonical_parent";
	
	//Observe the playing_slot_index property of this_track
	this_track.property = "playing_slot_index";
}

/**
 * Observe property changes.
 * 
 * @param Array args	The observed property name and it's value.
 */
function observe_property(args) {
	
	//Output the playing slot index each time the property is updated
	outlet(0,args[1]);
}