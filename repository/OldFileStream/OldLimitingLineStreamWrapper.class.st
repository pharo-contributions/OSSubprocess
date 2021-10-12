"
I'm a wrapper for a stream optimized for line-by-line access using #nextLine. My instances can be nested.

I read one line ahead. Reading terminates when the stream ends, or if the limitingBlock evaluated with the line answers true. To skip the delimiting line for further reading use #skipThisLine.

Character-based reading (#next) is permitted, too. Send #updatePosition when switching from line-based reading.

See examples at the class side.

--bf 2/19/1999 12:52
"
Class {
	#name : #OldLimitingLineStreamWrapper,
	#superclass : #Object,
	#instVars : [
		'stream',
		'line',
		'limitingBlock',
		'position'
	],
	#category : 'OldFileStream-Base'
}

{ #category : #examples }
OldLimitingLineStreamWrapper class >> example1 [
	<sampleInstance>
	"LimitingLineStreamWrapper example1"
	"Separate chunks of text delimited by a special string"
	| inStream msgStream messages |
	inStream := self exampleStream.
	msgStream := self on: inStream delimiter: 'From '.
	messages := OrderedCollection new.
	[inStream atEnd] whileFalse: [
		msgStream skipThisLine.
		messages add: msgStream upToEnd].
	^messages
			
]

{ #category : #examples }
OldLimitingLineStreamWrapper class >> example2 [
	<sampleInstance>
	"LimitingLineStreamWrapper example2"
	"Demo nesting wrappers - get header lines from some messages"
	| inStream msgStream headers headerStream |
	inStream := self exampleStream.
	msgStream := self on: inStream delimiter: 'From '.
	headers := OrderedCollection new.
	[inStream atEnd] whileFalse: [
		msgStream skipThisLine. "Skip From"
		headerStream := self on: msgStream delimiter: ''.
		headers add: headerStream linesUpToEnd.
		[msgStream nextLine isNil] whileFalse. "Skip Body"
	].
	^headers
			
]

{ #category : #examples }
OldLimitingLineStreamWrapper class >> exampleStream [
	<sampleInstance>
	^ 'From me@somewhere
From: me
To: you
Subject: Test

Test

From you@elsewhere
From: you
To: me
Subject: Re: test

okay
' readStream
]

{ #category : #deprecation }
OldLimitingLineStreamWrapper class >> isDeprecated [
	^true
]

{ #category : #'instance creation' }
OldLimitingLineStreamWrapper class >> on: aStream delimiter: aString [

	^self new setStream: aStream delimiter: aString

]

{ #category : #testing }
OldLimitingLineStreamWrapper >> atEnd [

	^line isNil or: [limitingBlock value: line]
]

{ #category : #'stream protocol' }
OldLimitingLineStreamWrapper >> close [
	^stream close
]

{ #category : #accessing }
OldLimitingLineStreamWrapper >> delimiter: aString [
	"Set limitBlock to check for a delimiting string. Be unlimiting if nil"

	self limitingBlock: (aString caseOf: {
		[nil] -> [[:aLine | false]].
		[''] -> [[:aLine | aLine size = 0]]
	} otherwise: [[:aLine | aLine beginsWith: aString]])

]

{ #category : #accessing }
OldLimitingLineStreamWrapper >> lastLineRead [
	"Return line last read. At stream end, this is the boundary line or nil"

	^ line
]

{ #category : #accessing }
OldLimitingLineStreamWrapper >> limitingBlock: aBlock [
	"The limitingBlock is evaluated with a line to check if this line terminates the stream"

	limitingBlock := aBlock.
	self updatePosition
]

{ #category : #accessing }
OldLimitingLineStreamWrapper >> linesUpToEnd [

	| elements ln |
	elements := OrderedCollection new.
	[(ln := self nextLine) isNil] whileFalse: [ 
		elements add: ln].
	^elements
]

{ #category : #accessing }
OldLimitingLineStreamWrapper >> next [
	"Provide character-based access"

	position ifNil: [^nil].
	position < line size ifTrue: [^line at: (position := position + 1)].
	line := stream nextLine.
	self updatePosition.
	^ Character cr
]

{ #category : #accessing }
OldLimitingLineStreamWrapper >> nextLine [

	| thisLine |
	self atEnd ifTrue: [^nil].
	thisLine := line.
	line := stream nextLine.
	^thisLine

]

{ #category : #accessing }
OldLimitingLineStreamWrapper >> peekLine [

	self atEnd ifTrue: [^nil].
	^ line
]

{ #category : #printing }
OldLimitingLineStreamWrapper >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: ' on '.
	stream printOn: aStream
]

{ #category : #private }
OldLimitingLineStreamWrapper >> setStream: aStream delimiter: aString [

	stream := aStream.
	line := stream nextLine.
	self delimiter: aString.	"sets position"

]

{ #category : #accessing }
OldLimitingLineStreamWrapper >> skipThisLine [

	line := stream nextLine.
	self updatePosition.

]

{ #category : #accessing }
OldLimitingLineStreamWrapper >> upToEnd [

	
	^String streamContents: [:strm | | ln |
		[(ln := self nextLine) isNil] whileFalse: [ 
			strm nextPutAll: ln; cr]]
]

{ #category : #accessing }
OldLimitingLineStreamWrapper >> updatePosition [
	"Call this before doing character-based access"

	position := self atEnd ifFalse: [0]
]
