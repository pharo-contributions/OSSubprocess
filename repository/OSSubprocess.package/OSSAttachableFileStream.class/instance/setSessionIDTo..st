private - hacks
setSessionIDTo: fileIDByteArray
	| currentSession oldFile |
	self flag: #fixMe. 
	"grrr I need the sessionID (first 4 bytes of the SQFile). .. there is no primitive to get it. Since it is the same for all files
	lets try to grab it from a file we know there will be always there: the image file."
	oldFile := StandardFileStream oldFileNamed: Smalltalk image imagePath.
	currentSession := oldFile getSQFilePointer.
	oldFile close.
	1 to: currentSession size do: [ :index | fileIDByteArray at: index put: (currentSession at: index) ]