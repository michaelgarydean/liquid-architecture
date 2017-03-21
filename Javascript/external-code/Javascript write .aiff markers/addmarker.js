

// sfmarkers goes JS
// pdelges@radiantslab.com
// users.skynet.be/crfmw/max

// 2005

autowatch = 1;


var theSourceFile;
var theDestinationFile;

var theMarkers;
var	lastMarkerID = -1 ;	// -1 means there is no marker

function bang()

{
	display();
}


function read (filename)

{

	theMarkers = new Array;		// fresh array

	var chunkTag = new Array (4);
	var chunkSize = new Array (4);

	theSourceFile = new File (filename, "read", "AIFF");
	
	post ("\nFile:",theSourceFile.filename, theSourceFile.isopen, "\n");

	theSourceFile.position += 12;		// skip start of header, should check file type

	if (searchMarkerChunk (theSourceFile))
	{
		readMarkerChunk (theSourceFile);
		// displayMarkers ();
	}
	else
		post ("nope\n");

	theSourceFile.close ();
}	

searchMarkerChunk.local = 1;
function searchMarkerChunk (theSourceFile)

{
	var chunkTag = new Array (4);
	var chunkSize = new Array (4);

	var chunkTagString = new String ;
	var chunckSizeInBytes = 0;

	var	theEof = theSourceFile.eof;
	
	do {		// let's jump from chunk to chunk
	
		// theSourceFile.position += parseInt(chunckSizeInBytes) ;
		
		chunkTag = theSourceFile.readbytes (4);
		chunkSize = theSourceFile.readbytes (4);
				
		chunckSizeInBytes = add4Bytes(chunkSize);
		
		chunkTagString = String.fromCharCode (chunkTag[0],chunkTag[1],chunkTag[2],chunkTag[3]);
	
		post ("Chunk", chunkTagString, "Size", chunckSizeInBytes,"pos:", theSourceFile.position, "\n");
		
	
	}
	while (chunkTagString != "MARK" && (theSourceFile.position += parseInt(chunckSizeInBytes)) < theEof);

	return (chunkTagString == "MARK");
}

readMarkerChunk.local = 1;
function readMarkerChunk (theSourceFile)

{
	var	numberOfMarkers;
	

	lastMarkerID = 0;
	
	numberOfMarkers = theSourceFile.readint16 (1);
	post ("number of markers:", numberOfMarkers, "\n");
	
	for (var i =0; i < numberOfMarkers; i++)
	{
		var aMarker = new Object;
		
		aMarker.id = theSourceFile.readint16 (1);
		lastMarkerID = Math.max (lastMarkerID, aMarker.id);

		aMarker.position = theSourceFile.readint32 (1);
		aMarker.nameLength = parseInt(theSourceFile.readbytes (1));
		aMarker.name = (theSourceFile.readchars (aMarker.nameLength)).join("");

		if (!(aMarker.nameLength % 2))	// beware useless "space padding" in Peak
			theSourceFile.position++;
			
		theMarkers.push (aMarker);
	}
	post ("lastID", lastMarkerID, "\n");

}


function display ()

{
	for (var i=0; i < theMarkers.length; i++)
	{
		var aMarker = theMarkers[i];
		for (var j in aMarker)
			post (j, aMarker[j], "-");
		post ("\n");
	
	}
}


function addMarker (name, position)

{
	var newMarker = new Object;
	
	newMarker.id = ++lastMarkerID;
	newMarker.position = position;
	newMarker.nameLength = name.length;
	newMarker.name = name;

	theMarkers.push (newMarker);

}


function saveFile (newFilename)

{
	theSourceFile.open ();		// open the last opened file
	theDestinationFile = new File (newFilename, "write", "AIFF");
	
	if (!theDestinationFile.isopen)
	{
		post ("Cannot create file", newFilename, "\n");
		return;	
	}
	
	theDestinationFile.writestring ("FORM");
	
	var totalSizePostion = theDestinationFile.position;
	theDestinationFile.writeint32 (0); // to be updated later
	
	theDestinationFile.writestring ("AIFF");
	
	// now, let's copy the chunks.
	
	var chunkTag = new Array (4);
	var chunkSize = new Array (4);

	var chunkTagString = new String ;
	var chunckSizeInBytes = 0;

	var	theEof = theSourceFile.eof;
	
	
	theSourceFile.position = 12;	// go back at start...
	
	do 
	{		// let's jump from chunk to chunk
	
		chunkTag = theSourceFile.readbytes (4);
		chunkSize = theSourceFile.readbytes (4);
		
		chunckSizeInBytes = add4Bytes(chunkSize);
		chunkTagString = String.fromCharCode (chunkTag[0],chunkTag[1],chunkTag[2],chunkTag[3]);
		
		if (chunkTagString == "MARK")	
			theSourceFile.position += parseInt(chunckSizeInBytes); // jump at the end of the chunk

		else  { if (chunkTagString == "COMM")
		{
			copyChunk ("COMM", chunckSizeInBytes);	// first we copy COMM
			post ("COMM ", chunckSizeInBytes, " ", theSourceFile.position, ".");
			writeNewMarkerChunk ();				// then MARK
		}
		
		else { if (chunkTagString != "MARK")			// MARK is already done
		{
			copyChunk (chunkTagString, chunckSizeInBytes);
			post (chunkTagString, chunckSizeInBytes, " ", theSourceFile.position, ".");
		}
		}
		}
		
	}
	while (theSourceFile.position < theEof);
	
	// update size of FORM
	
	theDestinationFile.position = 4;
	theDestinationFile.writeint32 (theDestinationFile.eof - 8);					

	
	theDestinationFile.close();
	theSourceFile.close();
}

writeNewMarkerChunk.local = 1;
function writeNewMarkerChunk ()

{

	var initialPositionInFile = theDestinationFile.position;

	theDestinationFile.writestring ("MARK");
	theDestinationFile.writeint32 (0);			// will be changed later
	theDestinationFile.writeint16 (theMarkers.length);

	for (var i=0; i < theMarkers.length; i++)
	{
		theDestinationFile.writeint16 (theMarkers[i].id);
		theDestinationFile.writeint32 (theMarkers[i].position);
		theDestinationFile.writebytes (theMarkers[i].nameLength);
		theDestinationFile.writestring (theMarkers[i].name);
		
		if (theDestinationFile.position % 2)
			theDestinationFile.writebytes (0);	// padding			
	}
	
	// write size of chunk
	
	var endPosition = theDestinationFile.position;
	var chunkSize = endPosition - initialPositionInFile;
	
	theDestinationFile.position = initialPositionInFile + 4;	// jump back
	theDestinationFile.writeint32 (chunkSize - 8);					
	
	theDestinationFile.position = endPosition;					// jump to end of chunk
}

copyChunk.local = 1;
function copyChunk(tag,size)

{
	var i;
	var	buffer;
	

	theDestinationFile.writestring (tag);
	theDestinationFile.writeint32 (size);
	
	if (size < 32)
		theDestinationFile.writebytes (theSourceFile.readbytes (size));
	
	else
		for (i=0;i<size;)
		{
			buffer = theSourceFile.readbytes (32);
	
			if (buffer.length)
			{
				i += buffer.length;
				theDestinationFile.writebytes (buffer);	
			}
			else
			{
				post ("weird!\n");
				break;
			}
		}
}


add4Bytes.local = 1;
function add4Bytes (anArray)

{
	var sum = 0;
	
	for (i=0,j=3; i<4; i++,j--) {
		sum += anArray[i] * Math.pow(256, j);
		// post (sum, anArray[i], Math.pow(256, j),"\n");  // remove later!
		}
	
	return sum.toFixed(0); // huge difference with float  !!!

}
