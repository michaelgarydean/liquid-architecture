/**
 * Report indexed source positions from spat.oper.
 *
 * Used to communicate position of sound sources 
 * to another system, such as Touchdesigner
 *
 * @author Michael Dean <myke@ckut.ca>
 */

inlets = 1;
outlets = 1;

/**
 * Report source positions by formatting the dumpout sourcespositions from spat.oper.
 *
 * @param List arguments	All source positions, in one list.
 */
function sourcespositions() {
	
	//Source index is the source as it's referred to by SPAT
	var source_index = 1;
	
	//Get the source positions from spat.oper and store as an array
	var sourcespositions = arrayfromargs(arguments);
	
	/**
	 * Group source positions by XYZ and output as a symbol to the first outlet.
	 */
	for(var i = 0; i < sourcespositions.length; i = i+3) {
		//Output XYZ positions
		outlet(0, "source " + source_index + " " + sourcespositions[i] + " " + sourcespositions[i+1] + " " + sourcespositions[i+2]);
		
		//Update source index to report next source
		source_index++;
	}
}