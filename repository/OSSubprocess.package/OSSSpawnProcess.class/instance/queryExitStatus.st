child status
queryExitStatus
	
	^ exitStatus ifNil: [ 
			exitStatus := OSSSystemAccessor current waitpidNoHang: self childPid.
			exitStatus
		]
		