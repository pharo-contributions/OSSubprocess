USING FROM OSPROCESS
primSendSigabrtTo: anIntegerPid
	"Send SIGABRT (abort) to the OS process identified by anIntegerPid.
	Answer 0 on success, -1 on failure, and nil if the pluggable primitive is not present."

	<primitive: 'primitiveSendSigabrtTo' module: 'UnixOSProcessPlugin'>
	^ nil

