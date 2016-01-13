child testing
getChildStatus
	| status |
	status := OSSSystemAccessor current waitpidNoHang: self childPid.
	^ status
		ifNil: [ nil ] 
		ifNotNil: [ OSSUnixProcessExitStatus for: status ]
	
	  