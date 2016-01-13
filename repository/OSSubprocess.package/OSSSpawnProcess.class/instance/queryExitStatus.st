child status
queryExitStatus
	
	^ exitStatus ifNil: [ 
			exitStatus := OSSSystemAccessor current waitpidNoHang: childPid.
			exitStatus
		]
		