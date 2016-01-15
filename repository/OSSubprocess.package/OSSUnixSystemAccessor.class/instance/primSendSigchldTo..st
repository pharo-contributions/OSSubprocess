USING FROM OSPROCESS
primSendSigchldTo: anIntegerPid
	"Send SIGCHLD (child status has changed, usually death of child) to the OS process
	identified by anIntegerPid.
	Answer 0 on success, -1 on failure, and nil if the pluggable primitive is not present."

	<primitive: 'primitiveSendSigchldTo' module: 'UnixOSProcessPlugin'>
	^ nil

