/**
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

runonload();

//These functions are only defined within the code 
//------------------------------------------
function runonload() {
    //if no argument has been specified, set the value to some default
    if (jsarguments[1] == undefined) {
        post("No abstraction specified in argument");
    } else {
       abstraction_name = jsarguments[1];
    }
}