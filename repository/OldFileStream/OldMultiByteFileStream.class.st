"
The central class to access the external file.  The interface of this object is similar to good old StandardFileStream, but internally it asks the converter, which is a sub-instance of TextConverter, and do the text conversion.

  It also combined the good old CrLfFileStream.  CrLfFileStream class>>new now returns an instance of MultiByteFileStream.

  There are several pitfalls:

  * You always have to be careful about the binary/text distinction.  In #text mode, it usually interpret the bytes.
  * A few file pointer operations treat the file as uninterpreted byte no matter what.  This means that if you use 'fileStream skip: -1', 'fileStream position: x', etc. in #text mode, the file position can be in the middle of multi byte character.  If you want to implement some function similar to #peek for example, call the saveStateOf: and restoreStateOf: methods to be able to get back to the original state.
  * #lineEndConvention: and #wantsLineEndConversion: (and #binary) can cause some puzzling situation because the inst var lineEndConvention and wantsLineEndConversion are mutated.  If you have any suggestions to clean up the protocol, please let me know.
"
Class {
	#name : 'OldMultiByteFileStream',
	#superclass : 'OldStandardFileStream',
	#instVars : [
		'converter',
		'lineEndConvention',
		'wantsLineEndConversion'
	],
	#classVars : [
		'Cr',
		'CrLf',
		'Lf',
		'LineEndDefault',
		'LineEndStrings',
		'LookAheadCount'
	],
	#category : 'OldFileStream-Base',
	#package : 'OldFileStream',
	#tag : 'Base'
}

{ #category : 'defaults' }
OldMultiByteFileStream class >> defaultToCR [

	"MultiByteFileStream defaultToCR"
	LineEndDefault := #cr.

]

{ #category : 'defaults' }
OldMultiByteFileStream class >> defaultToCRLF [

	"MultiByteFileStream defaultToCRLF"
	LineEndDefault := #crlf.
]

{ #category : 'defaults' }
OldMultiByteFileStream class >> defaultToLF [

	"MultiByteFileStream defaultToLF"
	LineEndDefault := #lf.

]

{ #category : 'defaults' }
OldMultiByteFileStream class >> guessDefaultLineEndConvention [
	"Lets try to guess the line end convention from what we know about the
	path name delimiter from FileDirectory."
	
	FileSystem disk delimiter = $:
		ifTrue: [^ self defaultToCR].
		
	FileSystem disk delimiter = $/
		ifTrue: [^ (Smalltalk os isMacOSX or: [Smalltalk os isUnix])
				ifTrue: [ self defaultToLF]
				ifFalse: [ self defaultToCR]].
			
	FileSystem disk delimiter = $\
		ifTrue: [^ self defaultToCRLF].
		
	"in case we don't know"
	^ self defaultToCR
]

{ #category : 'class initialization' }
OldMultiByteFileStream class >> initialize [
	Cr := Character cr.
	Lf := Character lf.
	CrLf := String with: Cr with: Lf.
	LineEndStrings := Dictionary new.
	LineEndStrings at: #cr put: (String with: Character cr).
	LineEndStrings at: #lf put: (String with: Character lf).
	LineEndStrings at: #crlf put: (String with: Character cr with: Character lf).
	LookAheadCount := 2048.
	
	SessionManager default registerSystemClassNamed: self name.
	self startUp.

]

{ #category : 'accessing' }
OldMultiByteFileStream class >> lineEndDefault [
	"Answer the default line-ending convention that will be used by default, which was determined at start-up by looking at platform attributes."
	^ LineEndDefault

]

{ #category : 'instance creation' }
OldMultiByteFileStream class >> newFrom: aFileStream [

	| rw n |
	n := aFileStream name.
	rw := aFileStream isReadOnly not.
	aFileStream close.
	^self new open: n forWrite: rw.

]

{ #category : 'system startup' }
OldMultiByteFileStream class >> startUp [
	self guessDefaultLineEndConvention.

]

{ #category : 'system startup' }
OldMultiByteFileStream class >> startUp: resuming [
	self guessDefaultLineEndConvention.

]

{ #category : 'remnant' }
OldMultiByteFileStream >> accepts: aSymbol [

 	^ converter accepts: aSymbol.

]

{ #category : 'modes' }
OldMultiByteFileStream >> ascii [

	super ascii.
	self detectLineEndConvention.

]

{ #category : 'private - crlf' }
OldMultiByteFileStream >> bareNext [

	 ^ self converter nextFromStream: self.

]

{ #category : 'file in/out' }
OldMultiByteFileStream >> basicChunk [
	"If our buffer in collection contains an chunk with no embedded !'s, nor
	any non-ascii characters, return that.
	This presumes the source code encoding is unambiguously ascii-compatible"
	| bufferIX goodString |
	"Not possible if read buffering disabled"
	collection ifNil: [^nil].
	^ ((bufferIX := (collection indexOf: $! startingAt: position + 1) min: readLimit +1) > 0
			and: [bufferIX < collection size
					and: [(collection at: bufferIX + 1)
								~= $!
							and: [goodString := collection copyFrom: position + 1 to: bufferIX - 1.
								goodString isAsciiString]]])
		ifTrue: [ position := bufferIX.
				goodString]
]

{ #category : 'private' }
OldMultiByteFileStream >> basicNext: anInteger [

	^ super next: anInteger.

]

{ #category : 'private' }
OldMultiByteFileStream >> basicNext: n into: aString [

	^ super next: n into: aString.

]

{ #category : 'private' }
OldMultiByteFileStream >> basicNext: anInteger putAll: aCollection startingAt: startIndex [


        ^super next: anInteger putAll: aCollection startingAt: startIndex
]

{ #category : 'private' }
OldMultiByteFileStream >> basicNextInto: aString [

	^ super nextInto: aString.

]

{ #category : 'private' }
OldMultiByteFileStream >> basicNextPut: char [

	^ super nextPut: char.

]

{ #category : 'private' }
OldMultiByteFileStream >> basicNextPutAll: aString [

	^ super nextPutAll: aString.

]

{ #category : 'private' }
OldMultiByteFileStream >> basicPeek [

	^ super peek

]

{ #category : 'private' }
OldMultiByteFileStream >> basicPosition [

	^ super position.

]

{ #category : 'private' }
OldMultiByteFileStream >> basicPosition: pos [

	^ super position: pos.

]

{ #category : 'private' }
OldMultiByteFileStream >> basicReadInto: byteArray startingAt: startIndex count: count [

	^ super readInto: byteArray startingAt: startIndex count: count.

]

{ #category : 'private' }
OldMultiByteFileStream >> basicSetToEnd [

	^ super setToEnd.

]

{ #category : 'private' }
OldMultiByteFileStream >> basicSkip: n [

	^ super skip: n.

]

{ #category : 'private' }
OldMultiByteFileStream >> basicUpTo: delim [

	^ super upTo: delim.

]

{ #category : 'private' }
OldMultiByteFileStream >> basicVerbatim: aString [

	^ super verbatim: aString.

]

{ #category : 'modes' }
OldMultiByteFileStream >> binary [

	super binary.
	self lineEndConvention: nil
]

{ #category : 'private - crlf' }
OldMultiByteFileStream >> convertStringFromCr: aString [ 
	| inStream outStream |
	lineEndConvention ifNil: [^ aString].
	lineEndConvention == #cr ifTrue: [^ aString].
	lineEndConvention == #lf ifTrue: [^ aString copy replaceAll: Cr with: Lf].
	"lineEndConvention == #crlf"
	inStream := aString readStream.
	outStream :=  (String new: aString size) writeStream.
	[inStream atEnd]
		whileFalse: 
			[outStream nextPutAll: (inStream upTo: Cr).
			(inStream atEnd not or: [aString last = Cr])
				ifTrue: [outStream nextPutAll: CrLf]].
	^ outStream contents
]

{ #category : 'private - crlf' }
OldMultiByteFileStream >> convertStringToCr: aString [ 
	| inStream outStream |
	lineEndConvention ifNil: [^ aString].
	lineEndConvention == #cr ifTrue: [^ aString].
	lineEndConvention == #lf ifTrue: [^ aString copy replaceAll: Lf with: Cr].
	"lineEndConvention == #crlf"
	inStream := aString readStream.
	outStream := (String new: aString size) writeStream.
	[inStream atEnd]
		whileFalse: 
			[outStream nextPutAll: (inStream upTo: Cr).
			(inStream atEnd not or: [aString last = Cr])
				ifTrue: 
					[outStream nextPut: Cr.
					inStream peek = Lf ifTrue: [inStream next]]].
	^ outStream contents
]

{ #category : 'accessing' }
OldMultiByteFileStream >> converter [

	converter ifNil: [self converter: TextConverter defaultSystemConverter].
	^ converter

]

{ #category : 'accessing' }
OldMultiByteFileStream >> converter: aConverter [

	converter := aConverter.
	self installLineEndConventionInConverter

]

{ #category : 'private - crlf' }
OldMultiByteFileStream >> detectLineEndConvention [
	"Detect the line end convention used in this stream. The result may be either #cr, #lf or #crlf."
	| char numRead state |
	self isBinary ifTrue: [^ self error: 'Line end conventions are not used on binary streams'].
	wantsLineEndConversion == true ifFalse: [self lineEndConvention: nil.
					^lineEndConvention].
	self closed ifTrue: [self lineEndConvention: LineEndDefault.
					^lineEndConvention].

	"Default if nothing else found"
	numRead := 0.
	state := self converter saveStateOf: self.
	lineEndConvention := nil.
	[super atEnd not and: [numRead < LookAheadCount]]
		whileTrue: 
			[char := self next.
			char = Lf
				ifTrue: 
					[converter restoreStateOf: self with: state.
					self lineEndConvention: #lf.
					^lineEndConvention].
			char = Cr
				ifTrue: 
					[self peek = Lf
						ifTrue: [self lineEndConvention: #crlf]
						ifFalse: [self lineEndConvention: #cr].
					converter restoreStateOf: self with: state.
					^ lineEndConvention].
			numRead := numRead + 1].
	converter restoreStateOf: self with: state.
	self lineEndConvention: LineEndDefault.
	^ lineEndConvention
]

{ #category : 'private - crlf' }
OldMultiByteFileStream >> doConversion [

	^wantsLineEndConversion == true and: [ lineEndConvention notNil ]
]

{ #category : 'accessing' }
OldMultiByteFileStream >> fileInEncodingName: aString [

	self converter: (TextConverter newForEncoding: aString).
	super fileIn.

]

{ #category : 'private' }
OldMultiByteFileStream >> installLineEndConventionInConverter [

	converter ifNotNil: [
		converter installLineEndConvention: (
			(wantsLineEndConversion == true and: [ lineEndConvention notNil ]) "#doConversion is inlined here"
				ifTrue: [ LineEndStrings at: lineEndConvention ]
				ifFalse: [ nil ]) ]
]

{ #category : 'accessing' }
OldMultiByteFileStream >> lineEndConvention [

	^lineEndConvention
]

{ #category : 'accessing' }
OldMultiByteFileStream >> lineEndConvention: aSymbol [

	(lineEndConvention := aSymbol) ifNotNil: [wantsLineEndConversion := true].
	self installLineEndConventionInConverter
]

{ #category : 'accessing' }
OldMultiByteFileStream >> next [

	| char secondChar state |
	char := (converter ifNil: [ self converter ]) nextFromStream: self.
	(wantsLineEndConversion == true and: [ lineEndConvention notNil ]) "#doConversion is inlined here"
		 ifTrue: [
			char == Cr ifTrue: [
				state := converter saveStateOf: self.
				secondChar := self bareNext.
				secondChar ifNotNil: [
					secondChar == Lf ifFalse: [ converter restoreStateOf: self with: state ] ].
				^Cr ].
			char == Lf ifTrue: [
				^Cr ] ].
	^char.


]

{ #category : 'accessing' }
OldMultiByteFileStream >> next: anInteger [ 

	| multiString |
	self isBinary ifTrue: [^ super next: anInteger].
	multiString := String new: anInteger.
	1 to: anInteger do: [:index |
		| character |
		(character := self next)
			ifNotNil: [ multiString at: index put: character ]
			ifNil: [
				multiString := multiString copyFrom: 1 to: index - 1.
				(wantsLineEndConversion == true and: [ lineEndConvention notNil ]) "#doConversion is inlined here"
					ifFalse: [ ^multiString ].
				^self next: anInteger innerFor: multiString ] ].
	(wantsLineEndConversion == true and: [ lineEndConvention notNil ]) "#doConversion is inlined here"
		 ifFalse: [ ^multiString ].

	multiString := self next: anInteger innerFor: multiString.
	(multiString size = anInteger or: [self atEnd]) ifTrue: [ ^ multiString].
	^ multiString, (self next: anInteger - multiString size).

]

{ #category : 'private - crlf' }
OldMultiByteFileStream >> next: n innerFor: aString [

	| peekChar state |
	"if we just read a CR, and the next character is an LF, then skip the LF"
	aString size = 0 ifTrue: [^ aString].
	(aString last = Character cr) ifTrue: [
		state := converter saveStateOf: self.
		peekChar := self bareNext.		"super peek doesn't work because it relies on #next"
		(peekChar notNil and: [peekChar ~= Character lf]) ifTrue: [
			converter restoreStateOf: self with: state.
		].
	].
 
	^ aString withInternalLineEndings.

]

{ #category : 'accessing' }
OldMultiByteFileStream >> next: anInteger putAll: aCollection startingAt: startIndex [


        (self isBinary or: [ aCollection class == ByteArray ]) ifTrue: [
                ^super next: anInteger putAll: aCollection startingAt: startIndex ].
        ^self converter next: anInteger putAll: aCollection startingAt: startIndex toStream: self
]

{ #category : 'file in/out' }
OldMultiByteFileStream >> nextChunk [
	"Answer the contents of the receiver, up to the next terminator
	character. Doubled terminators indicate an embedded terminator
	character."
	self skipSeparators.
	^ self
		parseLangTagFor: (self basicChunk
				ifNil: [String
						new: 1000
						streamContents: [:stream | 
							| character state |
							[(character := self next) == nil
								or: [character == $!
										and: [state := converter saveStateOf: self.
											self next ~~ $!]]]
								whileFalse: [stream nextPut: character].
							character
								ifNotNil: [converter restoreStateOf: self with: state.]]])
]

{ #category : 'accessing' }
OldMultiByteFileStream >> nextDelimited: terminator [

	| out ch save |
	out := (String new: 1000) writeStream.
	self atEnd ifTrue: [^ ''].
	save := converter saveStateOf: self.

	self next = terminator ifFalse: [
		"absorb initial terminator"
		converter restoreStateOf: self with: save.
	].
	[(ch := self next) == nil] whileFalse: [
		(ch = terminator) ifTrue: [
			self peek = terminator ifTrue: [
				self next.  "skip doubled terminator"
			] ifFalse: [
				^ out contents  "terminator is not doubled; we're done!"
			].
		].
		out nextPut: ch.
	].
	^ out contents.

]

{ #category : 'accessing' }
OldMultiByteFileStream >> nextMatchAll: aColl [

    | save |
    save := converter saveStateOf: self.
    aColl do: [:each |
       (self next) = each ifFalse: [
            converter restoreStateOf: self with: save.
            ^ false.
		].
	].
    ^ true.

]

{ #category : 'file in/out' }
OldMultiByteFileStream >> nextPreamble [
	"Assuming that preamble part does not contain ]lang[ tag"
	self skipSeparators.
	^ self basicChunk
				ifNil: [String
						new: 1000
						streamContents: [:stream | 
							| character state |
							[(character := self next) == nil
								or: [character == $!
										and: [state := converter saveStateOf: self.
											self next ~~ $!]]]
								whileFalse: [stream nextPut: character].
							character
								ifNotNil: [converter restoreStateOf: self with: state.]]]
]

{ #category : 'accessing' }
OldMultiByteFileStream >> nextPut: aCharacter [
	aCharacter isInteger 
		ifTrue: [ ^ super nextPut: aCharacter ].
	(wantsLineEndConversion == true and: [ lineEndConvention notNil ]) "#doConversion is inlined here"
		 ifTrue: [
			aCharacter = Cr
				ifTrue: [ converter nextPutAll: (LineEndStrings at: lineEndConvention) toStream: self ]
				ifFalse: [ converter nextPut: aCharacter toStream: self ].
			^aCharacter ].
	^ self converter nextPut: aCharacter toStream: self

]

{ #category : 'accessing' }
OldMultiByteFileStream >> nextPutAll: aCollection [
	^ (self isBinary or: [ aCollection class == ByteArray ])
		ifTrue: [ super nextPutAll: aCollection ]
		ifFalse: [ self converter nextPutAll: aCollection toStream: self ]
]

{ #category : 'open/close' }
OldMultiByteFileStream >> open: fileName forWrite: writeMode [ 
	| result |

	(writeMode and: [SessionManager default currentSession isReadOnlyAccessMode]) 
		ifTrue: [ ((CannotDeleteFileException fileName: fileName)
			messageText: 'Attempt to open file ' , fileName, ' as writable on read-only filesystem') signal. ].

	result := super open: fileName forWrite: writeMode.
	result ifNotNil: [
			converter ifNil: [self converter: UTF8TextConverter new].
			lineEndConvention ifNil: [ self detectLineEndConvention ]
	].
	^result
]

{ #category : 'accessing' }
OldMultiByteFileStream >> peek [
	"Answer what would be returned if the message next were sent to the receiver. If the receiver is at the end, answer nil.  "

	| next save |
	self atEnd ifTrue: [^ nil].
	save := converter saveStateOf: self.
	next := self next.
	converter restoreStateOf: self with: save.
	^ next.


]

{ #category : 'accessing' }
OldMultiByteFileStream >> peekFor: item [ 

	| next state |
	state := converter saveStateOf: self.
	(next := self next) == nil ifTrue: [^ false].
	item = next ifTrue: [^ true].
	converter restoreStateOf: self with: state.
	^ false.

]

{ #category : 'accessing' }
OldMultiByteFileStream >> readInto: buffer startingAt: offset count: requestedCount [
	"Read up to requestedCount elements into the given buffer starting at offset.
	Return the number of elements actually read.
	If I am binary or if buffer is a ByteArray, I skip decoding. Yes this is weird.
	This is a necessarily inefficient implementation, reading and decoding characters one by one."

	(self isBinary or: [ buffer class == ByteArray ])
		ifTrue: [ ^ super readInto: buffer startingAt: offset count: requestedCount ].
	0 to: requestedCount - 1 do: [ :count | 
		| element |
		(element := self next) ifNil: [ ^ count ].
		buffer at: offset + count put: element ].
	^ requestedCount
]

{ #category : 'private' }
OldMultiByteFileStream >> requestDropStream: dropIndex [
	"Needs to install proper converter"
	
	| result |
	result := super requestDropStream: dropIndex.
	result ifNotNil: [
		converter ifNil: [self converter: UTF8TextConverter new].
		lineEndConvention ifNil: [ self detectLineEndConvention] ].
	^result
]

{ #category : 'initialization' }
OldMultiByteFileStream >> reset [

	super reset.
	converter ifNil: [
		self converter: UTF8TextConverter new.
	].

]

{ #category : 'private' }
OldMultiByteFileStream >> setConverterForCode [

	| current |
	SourceFiles changesFileStream ifNotNil: [ :aStream |
		self fullName = aStream fullName ifTrue: [ ^ self ] ].
	current := self converter saveStateOf: self.
	self position: 0.
	self binary.
	((self next: 3) = #[ 16rEF 16rBB 16rBF ]) ifTrue: [
		self converter: UTF8TextConverter new
	] ifFalse: [
		self converter: MacRomanTextConverter new.
	].
	converter restoreStateOf: self with: current.
	self text.

]

{ #category : 'positioning' }
OldMultiByteFileStream >> skipSeparators [

	| state character |
	[ 
		state := converter saveStateOf: self.
		(character := self next) 
			ifNil: [ false ]
			ifNotNil: [ character isSeparator ] ] whileTrue.
	character ifNotNil: [ 
		converter restoreStateOf: self with: state ]
]

{ #category : 'accessing' }
OldMultiByteFileStream >> skipSeparatorsAndPeekNext [
	"Same as #skipSeparators, but returns the next character after the separators if such exists."

	| state character |
	[ 
		state := converter saveStateOf: self.
		(character := self next) 
			ifNil: [ false ]
			ifNotNil: [ character isSeparator ] ] whileTrue.
	character ifNotNil: [ 
		converter restoreStateOf: self with: state.
		^character ].
	
]

{ #category : 'accessing' }
OldMultiByteFileStream >> upTo: delimiter [

	^self collectionSpecies new: 1000 streamContents: [ :stream |
		| ch |
		[ (ch := self next) == nil or: [ ch = delimiter ] ] 
			whileFalse: [ stream nextPut: ch ] ]

]

{ #category : 'accessing' }
OldMultiByteFileStream >> upToAnyOf: delimiters do: aBlock [

	^self collectionSpecies new: 1000 streamContents: [ :stream |
		| ch |
		[ (ch := self next) == nil or: [ (delimiters includes: ch) and: [aBlock value: ch. true] ] ] 
			whileFalse: [ stream nextPut: ch ] ]
]

{ #category : 'accessing' }
OldMultiByteFileStream >> upToEnd [

	^self collectionSpecies
		new: self size - self position
		streamContents: [ :stream |
			| element |
			[ (element := self next) == nil ] whileFalse: [
				stream nextPut: element ] ]

]

{ #category : 'accessing' }
OldMultiByteFileStream >> upToPosition: anInteger [
	"Answer a subcollection containing items starting from the current position and ending including the given position. Usefully different to #next: in that positions measure *bytes* from the file, where #next: wants to measure *characters*."
	^self collectionSpecies new: 1000 streamContents: [ :stream |
		| ch |
		[ (ch := self next) == nil or: [ position > anInteger ] ] 
			whileFalse: [ stream nextPut: ch ] ]
]

{ #category : 'private - crlf' }
OldMultiByteFileStream >> wantsLineEndConversion [

	^wantsLineEndConversion == true

]

{ #category : 'remnant' }
OldMultiByteFileStream >> wantsLineEndConversion: aBoolean [
	
	wantsLineEndConversion :=  aBoolean.

	lineEndConvention ifNil: [ self detectLineEndConvention ]. 
]
