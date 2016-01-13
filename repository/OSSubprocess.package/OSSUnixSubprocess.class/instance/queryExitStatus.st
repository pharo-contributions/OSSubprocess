status
queryExitStatus
	
	^ exitStatus ifNil: [ 
			exitStatus := OSSSystemAccessor current waitpidNoHang: pid.
			exitStatus
		]
		