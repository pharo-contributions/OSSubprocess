accessing
upToPosition: anInteger
	"Answer a subcollection containing items starting from the current position and ending including the given position. Usefully different to #next: in that positions measure *bytes* from the file, where #next: wants to measure *characters*."
	^self collectionSpecies new: 1000 streamContents: [ :stream |
		| ch |
		[ (ch := self next) == nil or: [ position > anInteger ] ] 
			whileFalse: [ stream nextPut: ch ] ]