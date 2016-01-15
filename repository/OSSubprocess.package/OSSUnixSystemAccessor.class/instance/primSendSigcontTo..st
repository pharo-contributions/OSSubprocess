USING FROM OSPROCESS
primSendSigcontTo: anIntegerPid
	"Send SIGCONT (continue) to the OS process identified by anIntegerPid.
	Answer 0 on success, -1 on failure, and nil if the pluggable primitive is not present."

	<primitive: 'primitiveSendSigcontTo' module: 'UnixOSProcessPlugin'>
	^ nil

