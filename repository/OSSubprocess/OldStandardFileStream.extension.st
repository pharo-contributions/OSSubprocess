Extension { #name : 'OldStandardFileStream' }

{ #category : '*OSSubprocess' }
OldStandardFileStream >> atEndOfFile [
	"Answer whether the receiver is at its end based on the result of the last read operation. This uses feof() to test the underlying file stream status, and can be used as an alternative to #atEnd, which does not properly report end of file status for an OSPipe.
	
	Answer whether the file represented by #getFilePointerAsCFile is at end of file, as determined by a call to feof(). This is different from StandardFileStream>>primAtEnd: which answers true if the file pointer is at the end of the file, but which does not call feof() to determine that an end of file condition has occurred. The difference is significant	if aSqFileStruct represents a pipe. Another case where the difference is significant is when using StandardFileStream to communicate with a child process since  the SQFile will not automatically be updated if some other process has changed the actual size of the file.
	"

	^ fileID isNil or: [ self systemAccessor feof: self getFilePointerAsCFile ]

]

{ #category : '*OSSubprocess' }
OldStandardFileStream >> basicFileID [
	^ fileID
]

{ #category : '*OSSubprocess' }
OldStandardFileStream >> getFilePointerAsCFile [

	| pointerSize secondFieldStart secondFieldEnd |
	pointerSize := FFIExternalType pointerSize.
	secondFieldStart := pointerSize + 1.
	secondFieldEnd := secondFieldStart + pointerSize - 1.
	^ OSSCFile new 
		setHandle: (ExternalData 
							fromHandle: ((fileID copyFrom: secondFieldStart to: secondFieldEnd) asExternalPointer  ) 
							type: ExternalType void asPointerType);
		yourself
	



]

{ #category : '*OSSubprocess' }
OldStandardFileStream >> ossIsPipe [
	^ false
]

{ #category : '*OSSubprocess' }
OldStandardFileStream >> systemAccessor [
	^ OSSVMProcess vmProcess systemAccessor
]

{ #category : '*OSSubprocess' }
OldStandardFileStream >> upToEndOfFile [
	"Answer a subcollection from the current access position through the last element of the receiver.  Use #atEndOfFile to determine end of file status with feof(), required for reliable end of file test on OS pipes or in files that could have been written by another (child) process different than the VM process."
	

	| newStream buffer |
	self closed 
		ifTrue: [ self error: 'File already closed' ]
		ifFalse: [  
			buffer := buffer1 species new: 1000.
			newStream := WriteStream on: (buffer1 species new: 100).
			[self atEndOfFile] whileFalse: [newStream nextPutAll: (self nextInto: buffer)].
			^ newStream contents
		]
]
