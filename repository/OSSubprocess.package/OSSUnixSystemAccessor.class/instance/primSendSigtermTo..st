USING FROM OSPROCESS
primSendSigtermTo: anIntegerPid
	"Send SIGTERM (termination) to the OS process identified by anIntegerPid.
	Answer 0 on success, -1 on failure, and nil if the pluggable primitive is not present."

	<primitive: 'primitiveSendSigtermTo' module: 'UnixOSProcessPlugin'>
	^ nil

