"
OSSPipe represents a pipe provided by the underlying operating system, such as a Unix pipe. I have a reader stream and a writer stream which behave similarly to a read-only FileStream and a writeable FileStream. These streams are instances of OSSAttachableFileStream which are attached  to the underlying created  pipe (to either read and write end). 

The idea of OSSPipe is to provide an Stream-like API for pipes. The write-related methods will be delagated to the 'writer' (for example, #nextPutAll:) and the read-related methods (like #upToEnd) will be forwarded to the reader.

Thanks to the Stream-API, it almos allows a code user, to either use Pipes or regular files polymorphically.  In fact, OSSUnixSubprocess can either work with regular files or with OSSPipe for dealing with stdin, stdout and stderr. 

OSSPipe uses a single-character buffer to implement #peek without losing data from the external OS pipe.
"
Class {
	#name : 'OSSPipe',
	#superclass : 'Stream',
	#instVars : [
		'readBlocking',
		'writer',
		'reader',
		'nextChar'
	],
	#category : 'OSSubprocess',
	#package : 'OSSubprocess'
}

{ #category : 'instance creation' }
OSSPipe class >> newWith: fileIDsArray readBlocking: readBlocking [
	"fileIDsArray is an array of two elements where the first represents a sqFile struct of the reader of the pipe and the second represents the sqFile of the writer of the pipe. 
	If readBlocking is true, then the pipe will lock the reading waiting until there is data. If false, then the streams will not lock and answer immediatly instead.  
	 "
	^ self basicNew 
			initializeWith: fileIDsArray readBlocking: readBlocking
			yourself


]

{ #category : 'testing' }
OSSPipe >> atEnd [
	"Answer whether the receiver can access any more objects."

	^ writer closed and: [self peek == nil]

]

{ #category : 'testing' }
OSSPipe >> atEndOfFile [
	"Answer whether the receiver is at its end based on the result of
	the last read operation. This uses feof() to test the underlying file
	stream status, and can be used as an alternative to #atEnd, which
	does not properly report end of file status for an OSSPipe."

	^ reader atEndOfFile

]

{ #category : 'closing' }
OSSPipe >> close [
	"Closes both streams"
	
	self closeWriter.
	self closeReader.

]

{ #category : 'closing' }
OSSPipe >> closeReader [

	reader ifNotNil: [reader close]

]

{ #category : 'closing' }
OSSPipe >> closeWriter [

	writer ifNotNil: [writer close]

]

{ #category : 'testing' }
OSSPipe >> closed [

	^ reader closed
]

{ #category : 'accessing' }
OSSPipe >> contents [
	"Answer contents of the pipe, and return the contents to the pipe so it can still be read."

	| string |
	self closed ifTrue:
		[self notify: self printString, ' ', self reader printString, ' closed'.
		^ nil].
	string := self reader upToEnd.
	string isEmpty ifFalse:
		[self writer closed
			ifTrue: [self notify: self printString, ' ', self writer printString,
								' closed, cannot replace contents']
			ifFalse: [self nextPutAll: string]].
	^ string
]

{ #category : 'character writing' }
OSSPipe >> cr [
	"Append a return character to the receiver."

	self writer cr
]

{ #category : 'read, write, position' }
OSSPipe >> flush [
	^writer flush
]

{ #category : 'initialize - release' }
OSSPipe >> initializeWith: fileIDsArray readBlocking: aBoolean [
	super initialize.
	readBlocking := aBoolean.
	self openReadStreamFor: fileIDsArray first withName: 'pipeReader'.
	self openWriteStreamFor: fileIDsArray second withName: 'pipeWriter'.
]

{ #category : 'read, write, position' }
OSSPipe >> next [
	"Answer the next object accessible by the receiver."

	| character |
	nextChar isNil
		ifTrue:
			[^ [reader next]
				on: Error
				do: [nil]]
		ifFalse:
			[character := nextChar.
			nextChar := nil.
			^ character]

]

{ #category : 'read, write, position' }
OSSPipe >> next: anInteger [ 
	"Answer the next anInteger elements of my collection."

	| character stream |
	stream := WriteStream on: String new.
	(1 to: anInteger) do:
		[:index |
		character := self next.
		character isNil
			ifTrue: [^ stream contents]	
			ifFalse: [stream nextPut: character. false]].
	^ stream contents

]

{ #category : 'read, write, position' }
OSSPipe >> nextPut: anObject [ 
	"Insert the argument, anObject, as the next object accessible by the 
	receiver. Answer anObject."

	^ writer nextPut: anObject
]

{ #category : 'read, write, position' }
OSSPipe >> nextPutAll: aCollection [ 
	"Append the elements of aCollection to the sequence of objects accessible 
	by the receiver. Answer aCollection."

	^ writer nextPutAll: aCollection
]

{ #category : 'initialize - release' }
OSSPipe >> openReadStreamFor: aFileID withName: aReadStreamName [
	"Creates a read OSSAttachableFileStream for the read end of the pipe. 
	If the readBlock is false, then make the stream to be non blocking. "
	reader := OSSAttachableFileStream name: aReadStreamName attachTo: aFileID writable: false.
	readBlocking ifFalse: [ reader setNonBlocking ].
	^ reader
]

{ #category : 'initialize - release' }
OSSPipe >> openWriteStreamFor: aFileID withName: aWriteStreamName [
	"Creates a write OSSAttachableFileStream for the write end of the pipe.  "
	writer := OSSAttachableFileStream name: aWriteStreamName attachTo: aFileID writable: true.
	^ writer
]

{ #category : 'testing' }
OSSPipe >> ossIsPipe [

	^ true

]

{ #category : 'read, write, position' }
OSSPipe >> peek [

	^ nextChar isNil
		ifTrue: [reader closed
				ifFalse: [nextChar := reader next]]
		ifFalse: [nextChar]
]

{ #category : 'printing' }
OSSPipe >> printOn: aStream [
	"The implementation of Stream>>printOn: has bad side effects when used
	for OSPipe. This implementation is copied from Object."

	| title |
	title := self class name.
	aStream
		nextPutAll: (title first isVowel ifTrue: ['an '] ifFalse: ['a ']);
		nextPutAll: title
]

{ #category : 'accessing' }
OSSPipe >> reader [
	"Answer a stream on the read end of the pipe."

	^ reader
]

{ #category : 'accessing' }
OSSPipe >> reader: aReadStream [

	reader := aReadStream
]

{ #category : 'accessing' }
OSSPipe >> systemAccessor [
	^ OSSVMProcess vmProcess systemAccessor
]

{ #category : 'read, write, position' }
OSSPipe >> upToEnd [
	"Answer the remaining elements in the string."

	| strm s |
	strm := WriteStream on: String new.
	[(s := self next: 2000) isEmpty
		ifTrue: [^ strm contents]
		ifFalse: [strm nextPutAll: s]] repeat

]

{ #category : 'read, write, position' }
OSSPipe >> upToEndOfFile [
	"Answer the remaining elements in the pipe. Use #atEndOfFile to
	determine end of file status with feof(), required for reliable end of
	file test on OS pipes. Compare #upToEnd, which uses the generic end
	of file test in FilePlugin."

	| stream delay string |
	stream := WriteStream on: String new.
	delay := Delay forMilliseconds: 200.
	[(string := self next: 2000) isEmpty
		ifTrue: [self atEndOfFile
						ifTrue: [^ stream contents]
						ifFalse: [delay wait]]
		ifFalse: [stream nextPutAll: string]] repeat

]

{ #category : 'accessing' }
OSSPipe >> writer [
	"Answer a stream on the write end of the pipe."

	^ writer
]

{ #category : 'accessing' }
OSSPipe >> writer: aWriteStream [

	writer := aWriteStream
]
