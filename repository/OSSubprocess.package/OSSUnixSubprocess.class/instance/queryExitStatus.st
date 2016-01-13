status
queryExitStatus
	
	^ exitStatus ifNil: [ 
			exitStatus := self systemAccessor waitpidNoHang: pid.
			exitStatus
		]
		