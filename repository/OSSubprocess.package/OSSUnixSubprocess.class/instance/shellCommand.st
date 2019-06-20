shell
shellCommand
	"We first try to use the SHELL defined in the OS by getting the env variable $SHELL. 
	If not found, then we fallback to /bin/sh"
	^ Smalltalk platform environment at: 'SHELL' ifAbsent: ['/bin/sh']