accessing
contents
	"Answer with a copy of my collection from 1 to readLimit."

	| newArray |
	readLimit := readLimit max: position.
	isBinary ifFalse: [ "String"
		^ collection copyFrom: 1 to: readLimit].
	newArray := ByteArray new: readLimit.
	^ newArray replaceFrom: 1
		to: readLimit
		with: collection
		startingAt: 1.