USING FROM OSPROCESS
primSendSigquitTo: anIntegerPid
	"Send SIGQUIT (quit) to the OS process identified by anIntegerPid.
	Answer 0 on success, -1 on failure, and nil if the pluggable primitive is not present."

	<primitive: 'primitiveSendSigquitTo' module: 'UnixOSProcessPlugin'>
	^ nil

