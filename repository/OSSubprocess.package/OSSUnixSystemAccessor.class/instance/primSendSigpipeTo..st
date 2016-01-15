USING FROM OSPROCESS
primSendSigpipeTo: anIntegerPid
	"Send SIGPIPE (broken pipe) to the OS process identified by anIntegerPid.
	Answer 0 on success, -1 on failure, and nil if the pluggable primitive is not present."

	<primitive: 'primitiveSendSigpipeTo' module: 'UnixOSProcessPlugin'>
	^ nil

