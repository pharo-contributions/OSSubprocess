USING FROM OSPROCESS
primSendSigalrmTo: anIntegerPid
	"Send SIGALRM (alarm) to the OS process identified by anIntegerPid.
	Answer 0 on success, -1 on failure, and nil if the pluggable primitive is not present."

	<primitive: 'primitiveSendSigalrmTo' module: 'UnixOSProcessPlugin'>
	^ nil

