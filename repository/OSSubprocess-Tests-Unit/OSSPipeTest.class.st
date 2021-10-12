Class {
	#name : #OSSPipeTest,
	#superclass : #OSSAbstractUnixSubprocessTest,
	#category : 'OSSubprocess-Tests-Unit'
}

{ #category : #private }
OSSPipeTest >> blockingPipe [
	^ self systemAccessor makeBlockingPipe
	
]

{ #category : #private }
OSSPipeTest >> nonBlockingPipe [
	^ self systemAccessor makeNonBlockingPipe
	
]

{ #category : #private }
OSSPipeTest >> readFromAndClose: aPipe writingTo: aStream [

	| s |
	[aPipe atEndOfFile] whileFalse:
		[s := aPipe next: 10000.
		aStream nextPutAll: s asString.
		(Delay forMilliseconds: 100) wait].
	(aPipe respondsTo: #reader) ifTrue: [aPipe reader close].
	^ aStream

]

{ #category : #testing }
OSSPipeTest >> testBasicWriteAndRead [
	| pipe string readString |
	string := 'this is a testing string'. 
	pipe := self blockingPipe.
	pipe writer nextPutAll: string; flush.
	readString := pipe reader next: string size.
	self assert: string equals: readString
]

{ #category : #testing }
OSSPipeTest >> testBlocking [

	| pipe |
	pipe := self blockingPipe.
	(1 to: 10) do: [:i | pipe nextPutAll: 'this is line ', i printString; cr].
	pipe flush. "protect against buggy clib that may never flush output"
	self should: ['this is line 1*' match: (pipe next: 15)].
	self should: ['this is line 2*' match: (pipe next: 15)].
	self should: ['this is line 3*' match: (pipe next: 15)].
	self should: ['this is line 4*' match: (pipe next: 15)].
	self should: ['this is line 5*' match: (pipe next: 15)].
	self should: ['this is line 6*' match: (pipe next: 15)].
	self should: ['this is line 7*' match: (pipe next: 15)].
	self should: ['this is line 8*' match: (pipe next: 15)].
	self should: ['this is line 9*' match: (pipe next: 15)].
	pipe writer close.
	self shouldnt: pipe atEnd.
	self should: ['this is line 10*' match: (pipe next: 16)].
	self should: pipe atEnd.
	pipe close

]

{ #category : #testing }
OSSPipeTest >> testBlockingPeek [

		| pipe |
	pipe := self blockingPipe.
	pipe nextPutAll: 'abc'.
	pipe flush. "protect against buggy clib that may never flush output"
	self assert: (pipe peek == $a).
	self assert: (pipe next == $a).
	self assert: (pipe peek == $b).
	self assert: (pipe next == $b).
	self assert: (pipe peek == $c).
	self deny: pipe atEnd.
	self assert: (pipe next == $c).
	self deny: pipe atEnd.
	pipe closeWriter.
	self assert: pipe atEnd.
	pipe close

]

{ #category : #testing }
OSSPipeTest >> testIsAtEndOfFile [

	| pipe |
	pipe := self nonBlockingPipe.

	self deny: (pipe reader atEndOfFile).
	self deny: pipe reader atEnd.
	self deny: pipe atEnd.
	self assert: (pipe reader basicNext == nil).
	self deny: (pipe reader atEndOfFile).
	self deny: pipe reader atEnd.
	self deny: pipe atEnd.
	pipe writer nextPut: $X; flush.
	self assert: (pipe reader basicNext == $X).
	self deny: (pipe reader atEndOfFile).
	self deny: pipe reader atEnd.
	self deny: pipe atEnd.
	self assert: (pipe reader basicNext == nil).
	self deny: (pipe reader atEndOfFile).
	self deny: pipe reader atEnd.
	self deny: pipe atEnd.

	pipe writer close.
	self deny: (pipe reader atEndOfFile).
	self deny: pipe atEndOfFile. "no read yet, so flag has not been set"
	
	"From Pharo 7 on, #atEnd does detect EOF on a pipe"
	SystemVersion current major >= 7
		ifTrue: [ self assert: pipe reader atEnd ].

	self assert: pipe atEnd. "writer closed and read gives nil"

	self assert: (pipe reader basicNext == nil). "read operation should set flag"
	self assert: (pipe reader atEndOfFile).

	"From Pharo 7 on, #atEnd does detect EOF on a pipe"
	SystemVersion current major >= 7
		ifTrue: [ self assert: pipe reader atEnd ].
	
	self assert: pipe reader atEndOfFile.
	self assert: pipe atEnd.
	pipe close

]

{ #category : #testing }
OSSPipeTest >> testIsAtEndOfFile2 [

	| pipe string |
	pipe := self nonBlockingPipe.
	[pipe nextPutAll: 'hello'; flush.
	string := pipe next: 100.
	self assert: string = 'hello'.
	self deny: pipe atEndOfFile.
	pipe closeWriter.
	self deny: pipe atEndOfFile.
	string := pipe next: 100.
	self assert: string = ''.
	self assert: pipe atEndOfFile]
		ensure: [pipe close]

]

{ #category : #testing }
OSSPipeTest >> testNonBlocking [

	| pipe writeStream string |
	pipe := self nonBlockingPipe.
	self writeStuffOnThenClose: pipe.
	writeStream := self readFromAndClose: pipe writingTo: (WriteStream on: String new).
	string := (writeStream contents last: 16).
	self should: ['this is line 10*' match: string].
	pipe close

]

{ #category : #testing }
OSSPipeTest >> testNonBlockingPeek [

	| pipe |
	pipe := self nonBlockingPipe.
	pipe nextPutAll: 'abc'; flush.
	self assert: (pipe peek == $a).
	self assert: (pipe next == $a).
	self assert: (pipe peek == $b).
	self assert: (pipe next == $b).
	self assert: (pipe peek == $c).
	self deny: pipe atEnd.
	self assert: (pipe next == $c).
	self deny: pipe atEnd.
	pipe closeWriter.
	self assert: pipe atEnd.
	pipe close

]

{ #category : #testing }
OSSPipeTest >> testReadAfterClosedReadEnd [
	| pipe writeStream readStream string |
	string := 'this is a testing string'. 
	pipe := self blockingPipe.
	pipe writer nextPutAll: string; flush.
	readStream := pipe reader.
	pipe closeReader.
	self assert: readStream closed.
	self should: [ readStream upToEndOfFile ] raise: Error.
	self should: [ readStream upToEnd ] raise: Error.
	
]

{ #category : #testing }
OSSPipeTest >> testWriteAfterClosedWriteEnd [
	| pipe writeStream string |
	string := 'this is a testing string'. 
	pipe := self blockingPipe.
	pipe closeWriter.
	self should: [ pipe writer nextPutAll: string; flush ] raise: Error.
	
]

{ #category : #private }
OSSPipeTest >> writeStuffOnThenClose: aPipe [

	^ [(1 to: 10) do:
		[:i |
		[aPipe nextPutAll: 'this is line ', i printString; cr]
			on: Error
			do: ["Ignore error. Test case will still fail, and throwing an error in this
				process would cause a debugger to be scheduled inconveniently."].
		(Delay forMilliseconds: 50) wait].
	(aPipe respondsTo: #writer)
		ifTrue: [[aPipe writer close]
					on: Error
					do: ["Ignore error to avoid a debugger"]]
		ifFalse: [[aPipe close]
					on: Error
					do: ["Ignore error to avoid a debugger"]]]
		forkAt: Processor userBackgroundPriority
]
