child status
exitStatusInterpreter
	^ exitStatus ifNotNil: [ OSSUnixProcessExitStatus for: exitStatus ]