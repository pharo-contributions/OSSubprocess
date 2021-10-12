"
This package is to support the migration of OSSubProcess to Pharo 9.0 where FileStream has been removed after been deprecated in Pharo 8.0.




A simulation of a FileStream, but living totally in memory.  Hold the contents of a file or web page from the network.  Can then fileIn like a normal FileStream.

Need to be able to switch between binary and text, as a FileStream does, without recopying the whole collection.  Convert to binary upon input and output.  Always keep as text internally.
"
Class {
	#name : #OldRWBinaryOrTextStream,
	#superclass : #ReadWriteStream,
	#instVars : [
		'isBinary'
	],
	#category : 'OldFileStream-Base'
}

{ #category : #deprecation }
OldRWBinaryOrTextStream class >> isDeprecated [
	^true
]

{ #category : #converting }
OldRWBinaryOrTextStream >> asBinaryOrTextStream [

	^ self
]

{ #category : #modes }
OldRWBinaryOrTextStream >> ascii [
	isBinary := false
]

{ #category : #modes }
OldRWBinaryOrTextStream >> binary [
	isBinary := true
]

{ #category : #accessing }
OldRWBinaryOrTextStream >> contents [
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
]

{ #category : #testing }
OldRWBinaryOrTextStream >> isBinary [
	^ isBinary
]

{ #category : #accessing }
OldRWBinaryOrTextStream >> next [

	| byte |
	^ isBinary 
			ifTrue: [byte := super next.
				 byte ifNil: [nil] ifNotNil: [byte asciiValue]]
			ifFalse: [super next].

]

{ #category : #accessing }
OldRWBinaryOrTextStream >> next: anInteger [ 
	"Answer the next anInteger elements of my collection. Must override to get class right."

	| newArray |
	newArray := (isBinary ifTrue: [ByteArray] ifFalse: [ByteString]) new: anInteger.
	^ self nextInto: newArray
]

{ #category : #accessing }
OldRWBinaryOrTextStream >> next: n into: aCollection startingAt: startIndex [
	"Read n objects into the given collection. 
	Return aCollection or a partial copy if less than n elements have been read."
	"Overriden for efficiency"
	| max |
	max := (readLimit - position) min: n.
	aCollection 
		replaceFrom: startIndex 
		to: startIndex+max-1
		with: collection
		startingAt: position+1.
	position := position + max.
	max = n
		ifTrue:[^aCollection]
		ifFalse:[^aCollection copyFrom: 1 to: startIndex+max-1]
]

{ #category : #accessing }
OldRWBinaryOrTextStream >> next: anInteger putAll: aCollection startingAt: startIndex [
	"Optimized for ByteArrays"
	aCollection class == ByteArray 
		ifTrue:[^super next: anInteger putAll: aCollection asString startingAt: startIndex].
	^super next: anInteger putAll: aCollection startingAt: startIndex
]

{ #category : #accessing }
OldRWBinaryOrTextStream >> nextPut: charOrByte [
	^ super nextPut: charOrByte asCharacter
]

{ #category : #accessing }
OldRWBinaryOrTextStream >> nextPutAll: aCollection [
	"Optimized for ByteArrays"
	^ aCollection class == ByteArray 
		ifTrue: [ super nextPutAll: aCollection asString ]
		ifFalse: [ super nextPutAll: aCollection ]
]

{ #category : #converting }
OldRWBinaryOrTextStream >> on: aCollection [

	super on: aCollection.
	readLimit := 0
]

{ #category : #accessing }
OldRWBinaryOrTextStream >> padToEndWith: aChar [
	"We don't have pages, so we are at the end, and don't need to pad."
]

{ #category : #accessing }
OldRWBinaryOrTextStream >> readInto: aCollection startingAt: startIndex count: n [
	"Read n objects into the given collection. 
	Return number of elements that have been read."
	"Overriden for efficiency"
	| max |
	max := (readLimit - position) min: n.
	aCollection 
		replaceFrom: startIndex 
		to: startIndex + max - 1
		with: collection
		startingAt: position + 1.
	position := position + max.
	^ max
]

{ #category : #initialization }
OldRWBinaryOrTextStream >> reset [
	"Set the receiver's position to the beginning of the sequence of objects."

	super reset.
	isBinary ifNil: [isBinary := false].
	collection class == ByteArray ifTrue: ["Store as String and convert as needed."
		collection := collection asString.
		isBinary := true].

]

{ #category : #modes }
OldRWBinaryOrTextStream >> text [
	isBinary := false
]

{ #category : #accessing }
OldRWBinaryOrTextStream >> upTo: anObject [ 
	"Answer a subcollection from the current access position to the 
	occurrence (if any, but not inclusive) of anObject in the receiver. If 
	anObject is not in the collection, answer the entire rest of the receiver."
	| newStream element species |
	species := isBinary ifTrue:[ByteArray] ifFalse:[String].
	newStream := WriteStream on: (species new: 100).
	[self atEnd or: [(element := self next) = anObject]]
		whileFalse: [newStream nextPut: element].
	^newStream contents
]

{ #category : #accessing }
OldRWBinaryOrTextStream >> upToEnd [
	"Must override to get class right."
	| newArray |
	newArray := (isBinary ifTrue: [ByteArray] ifFalse: [ByteString]) new: self size - self position.
	^ self nextInto: newArray
]
