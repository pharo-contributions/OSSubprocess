child testing
getChildStatus
	| statusPointer |
	statusPointer := OSSSystemAccessor current waitpidNoHang: self childPid.
	^ statusPointer
		ifNil: [ nil ] 
		ifNotNil: [ (OSSUnixProcessExitStatus for: (statusPointer nbInt32AtOffset: 0)) ]
	
	  