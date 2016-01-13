running
run
	| cFile |
	cFile := self primitivePopen: self commandPreparedToBeRun mode: self mode.
	cFile ifNil: [ self perror: 'popen()' ].
	pipeStream := self isRead 
						ifTrue: [(OSSAttachableFileStream name: 'pipeReader' attachTo: cFile writable: false) ] 
						ifFalse: [ (OSSAttachableFileStream name: 'pipeWriter' attachTo: cFile writable: true) ].
	pipeStream flush. 						
	