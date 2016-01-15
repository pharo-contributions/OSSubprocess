USING FROM OSPROCESS
primSendSigintTo: anIntegerPid
	"Send SIGINT (interrupt) to the OS process identified by anIntegerPid.
	Answer 0 on success, -1 on failure, and nil if the pluggable primitive is not present."

	<primitive: 'primitiveSendSigintTo' module: 'UnixOSProcessPlugin'>
	^ nil

