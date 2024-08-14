"
OSSAttachableFileStream represents a  stream on an input or output channel provided by the underlying operating system. It behaves like an ordinary file stream, except that it can be attached myself to an input or output stream which has already been opened by the underlying operating system.

The most common use is to represent either the read or write end of a Pipe from the  Operatying System . This way, it provides a Stream API for both, reading and writing. An OSSPipe  contains a 'reader' and a 'writer' which will be two different instances of this class.
"
Class {
	#name : 'OSSAttachableFileStream',
	#superclass : 'OldStandardFileStream',
	#instVars : [
		'autoClose'
	],
	#category : 'OSSubprocess',
	#package : 'OSSubprocess'
}

{ #category : 'file creation' }
OSSAttachableFileStream class >> fileNamed: fileName [
	"Since this is an attacheable stream it means the underlying stream in the OS
	has already been opened"

	self shouldNotImplement

]

{ #category : 'file creation' }
OSSAttachableFileStream class >> isAFileNamed: fileName [
	"Since this is an attacheable stream it means the underlying stream in the OS
	has already been opened"

	self shouldNotImplement

]

{ #category : 'instance creation' }
OSSAttachableFileStream class >> name: aSymbolOrString attachTo: aFileID writable: readWriteFlag [ 
	"Create a new instance attached to aFileID. For write streams, this represents two
	Smalltalk streams which write to the same OS file or output stream,
	presumably with interleaved output. The purpose of this method is to
	permit a FileStream to be attached to an existing aFileID, such as
	the handle for standard input, standard output, and standard error."

	^ (super basicNew
		name: aSymbolOrString
		attachTo: aFileID
		writable: readWriteFlag) initialize
]

{ #category : 'TO USE LATER WITHOUT OSPROCESS' }
OSSAttachableFileStream class >> name: aSymbolOrString attachToCFile: aCFile writable: readWriteFlag [ 
	"Create a new instance attached to aCFile. For write streams, this represents two
	Smalltalk streams which write to the same OS file or output stream,
	presumably with interleaved output. The purpose of this method is to
	permit a FileStream to be attached to an existing aCFile, such as
	the handle for standard input, standard output, and standard error."

	^ (super basicNew
		name: aSymbolOrString
		attachToCFile: aCFile
		writable: readWriteFlag) initialize
]

{ #category : 'file creation' }
OSSAttachableFileStream class >> newFileNamed: fileName [
	"Since this is an attacheable stream it means the underlying stream in the OS
	has already been opened"
	
	self shouldNotImplement

]

{ #category : 'file creation' }
OSSAttachableFileStream class >> oldFileNamed: fileName [
	"Since this is an attacheable stream it means the underlying stream in the OS
	has already been opened"
	
	self shouldNotImplement

]

{ #category : 'file creation' }
OSSAttachableFileStream class >> readOnlyFileNamed: fileName [
	"Since this is an attacheable stream it means the underlying stream in the OS
	has already been opened"
	
	self shouldNotImplement

]

{ #category : 'registry' }
OSSAttachableFileStream class >> register: anObject [
	"An attachable file stream is generally either a second reference to an
	existing file stream, or a reference to a transient object such as a pipe
	endpoint. There is no need to register it for finalization."

	^ anObject
]

{ #category : 'registry' }
OSSAttachableFileStream class >> unregister: anObject [
	"An attachable file stream is generally either a second reference to an
	existing file stream, or a reference to a transient object such as a pipe
	endpoint. There is no need to register it for finalization."

	^ anObject
]

{ #category : 'converting' }
OSSAttachableFileStream >> asAttachableFileStream [

	^ self

]

{ #category : 'finalization' }
OSSAttachableFileStream >> autoClose [
	"Private. Answer true if the file should be automatically closed when 
	this object is finalized."

	^ autoClose
		ifNil: [autoClose := true]
]

{ #category : 'open/close' }
OSSAttachableFileStream >> close [
	"Close this file."

	| handle |
	(handle := self basicFileID) ifNotNil: [
		self primCloseNoError: handle.
		self unregister.
		fileID := nil
	]

]

{ #category : 'open/close' }
OSSAttachableFileStream >> ensureOpen [
	"Since this is an attacheable stream it means the underlying stream in the OS
	has already been opened"

	self shouldNotImplement

]

{ #category : 'finalization' }
OSSAttachableFileStream >> finalize [
	"If #autoClose is true, then we try to close the stream upon finalization - GC "
	
	self autoClose
		ifTrue: [[self primCloseNoError: fileID] on: Error do: []]
]

{ #category : 'read, write, position' }
OSSAttachableFileStream >> flush [
	"Flush the external OS stream (the one in the C library)."
	
	self systemAccessor fflush: self getFilePointerAsCFile
]

{ #category : 'finalization' }
OSSAttachableFileStream >> keepOpen [
	"Do not allow the file to be closed when this object is finalized."

	autoClose := false

]

{ #category : 'attaching' }
OSSAttachableFileStream >> name: aSymbolOrString attachTo: aFileID writable: readWriteFlag [
	"Attach to an existing file handle, assumed to have been previously
	 opened by the underlying operating system.
	"
	
	name := aSymbolOrString.
	fileID := aFileID.
	readWriteFlag ifTrue: [self readWrite] ifFalse: [self readOnly].
	self ascii.
	self register


]

{ #category : 'TO USE LATER WITHOUT OSPROCESS' }
OSSAttachableFileStream >> name: aSymbolOrString attachToCFile: externalFilePointer writable: readWriteFlag [
	"Attach to an existing file handle, assumed to have been previously opened by the underlying operating system.
	We assume a 32 bits machine and here we document the SQFile used by the VM:
	/* squeak file record; see sqFilePrims.c for details */
typedef struct {
  int			 sessionID;	/* ikp: must be first */
  void			*file;
  squeakFileOffsetType	 fileSize;	/* 64-bits we hope. */
  char			 writable;
  char			 lastOp; /* 0 = uncommitted, 1 = read, 2 = write */
  char			 lastChar;
  char			 isStdioStream;
} SQFile;
	"
	| fileIDByteArray |
	self flag: #fixIt.
	"Hack...I calculated that the size of the SQFile struct in a 32 bits machine is 20 bytes only
	if the fileSize was 64 bits. This is the case of Pharo OSX VM. However, Linux VM has not yet been build
	with 64 buts but 32 bits for fileSize and so, instead of 20 it is 16.
	For more details read thread with subject 'Why StandardFileStream fileID is 16 bytes in Linux while 20 bytes in OSX?'
	"
	fileIDByteArray := ByteArray new: 20. 
	name := aSymbolOrString.
	self setSessionIDTo: fileIDByteArray.
	"Hack. I calculated that the File* of the SQFile is the second element of the struct and starts at the byte 5.
	The first 4 byets is the session ID. "
	self setOSFilePointerFromByteArray: externalFilePointer getHandle getHandle asByteArrayPointer to: fileIDByteArray offset: 4.
	readWriteFlag 
		ifTrue: [
			self flag: #fixIt.
			"Again, in 32 bytes machines, the byte17 is the variable 'writable' from the SQFile. 
			In Linux, instead if 17 it should be 13.
			 "
			fileIDByteArray at: 17 put: 1.
			self readWrite] 
		ifFalse: [
			self readOnly].
	fileID := fileIDByteArray.
	self ascii.
	self register

]

{ #category : 'TO USE LATER WITHOUT OSPROCESS' }
OSSAttachableFileStream >> oldname: aSymbolOrString attachTo: externalFilePointer writable: readWriteFlag [
	"Attach to an existing file handle, assumed to have been previously opened by the underlying operating system.
	We assume a 32 bits machine and here we document the SQFile used by the VM:
	/* squeak file record; see sqFilePrims.c for details */
typedef struct {
  int			 sessionID;	/* ikp: must be first */
  void			*file;
  squeakFileOffsetType	 fileSize;	/* 64-bits we hope. */
  char			 writable;
  char			 lastOp; /* 0 = uncommitted, 1 = read, 2 = write */
  char			 lastChar;
  char			 isStdioStream;
} SQFile;
	"
	| fileIDByteArray |
	"Hack...I calculated that the size of the SQFile struct in a 32 bits machine is 20 bytes. "
	fileIDByteArray := ByteArray new: 20. 
	name := aSymbolOrString.
	self setSessionIDTo: fileIDByteArray.
	"Hack. I calculated that the File* of the SQFile is the second element of the struct and starts at the byte 5.
	The first 4 byets is the session ID. "
	self setOSFilePointerFromByteArray: externalFilePointer getHandle getHandle asByteArrayPointer to: fileIDByteArray offset: 4.
	readWriteFlag 
		ifTrue: [
			"Again, in 32 bytes machines, the byte17 is the variable 'writable' from the SQFile.  "
			fileIDByteArray at: 17 put: 1.
			self readWrite] 
		ifFalse: [
			self readOnly].
	fileID := fileIDByteArray.
	self ascii.
	self register

]

{ #category : 'open/close' }
OSSAttachableFileStream >> open [
	"Since this is an attacheable stream it means the underlying stream in the OS
	has already been opened"
	
	self shouldNotImplement

]

{ #category : 'open/close' }
OSSAttachableFileStream >> open: fileName forWrite: writeMode [
	"Since this is an attacheable stream it means the underlying stream in the OS
	has already been opened"
	
	self shouldNotImplement

]

{ #category : 'open/close' }
OSSAttachableFileStream >> openReadOnly [
	"Since this is an attacheable stream it means the underlying stream in the OS
	has already been opened"
	
	self shouldNotImplement

]

{ #category : 'read, write, position' }
OSSAttachableFileStream >> position [
	"Return the receiver's current file position. If the stream is not positionable,
	as in the case of a Unix pipe stream, answer 0."

	^ [super position]
		on: Error
		do: [0]

]

{ #category : 'open/close' }
OSSAttachableFileStream >> reopen [
	"Since this is an attacheable stream it means the underlying stream in the OS
	has already been opened"
	
	self shouldNotImplement

]

{ #category : 'non blocking' }
OSSAttachableFileStream >> setNonBlocking [
	"Make this stream to be none blocking. In Linux it means 
	calling fcntl() to set the file non-blocking (O_NONBLOCK)." 

	self systemAccessor makeFileNoneBocking: fileID
]

{ #category : 'TO USE LATER WITHOUT OSPROCESS' }
OSSAttachableFileStream >> setOSFilePointerFromByteArray: externalFilePointer to: aDestByteArray offset: anOffsetNumber [
	1 to: 4 do: [ :index | aDestByteArray at: (index + anOffsetNumber) put: (externalFilePointer at: index) ]
	
]

{ #category : 'TO USE LATER WITHOUT OSPROCESS' }
OSSAttachableFileStream >> setSessionIDTo: fileIDByteArray [
	| currentSession |
	currentSession := OSSVMProcess vmProcess sessionID.
	1 to: currentSession size do: [ :index | fileIDByteArray at: index put: (currentSession at: index) ]
]

{ #category : 'read, write, position' }
OSSAttachableFileStream >> upToEnd [
	"Answer a subcollection from the current access position through the last element
	of the receiver. This is slower than the method in StandardFileStream, but it
	works with pipes which answer false to #atEnd when no further input is
	currently available, but the pipe is not yet closed."

	| newStream buffer nextBytes |
	buffer := buffer1 species new: 1000.
	newStream := WriteStream on: (buffer1 species new: 100).
	[self atEnd or: [(nextBytes := self nextInto: buffer) isEmpty]]
		whileFalse: [newStream nextPutAll: nextBytes].
	^ newStream contents

]
