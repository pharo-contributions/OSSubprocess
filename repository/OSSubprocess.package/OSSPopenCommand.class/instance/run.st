running
run
	| cFile |
	cFile := self primitivePopen: self commandPreparedToBeRun mode: self mode.
	cFile isNull ifTrue: [ self perror: 'popen()' ].
	pipeStream := self isRead 
						ifTrue: [(OSSAttachableFileStream name: 'pipeReader' attachToCFile: cFile writable: false) ] 
						ifFalse: [ (OSSAttachableFileStream name: 'pipeWriter' attachToCFile: cFile writable: true) ].
	pipeStream flush. 						
	