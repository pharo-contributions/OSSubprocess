instance creation
name: aSymbolOrString attachTo: anIOHandle writable: readWriteFlag 
	"Create a new instance attached to anIOHandle, where anIOHandle
	represents an open IO channel. For write streams, this represents two
	Smalltalk streams which write to the same OS file or output stream,
	presumably with interleaved output. The purpose of this method is to
	permit a FileStream to be attached to an existing IOHandle, such as
	the IOHandle for standard input, standard output, and standard error."

	^ (super basicNew
		name: aSymbolOrString
		attachTo: anIOHandle
		writable: readWriteFlag) initialize