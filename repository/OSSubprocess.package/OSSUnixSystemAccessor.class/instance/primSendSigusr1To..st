USING FROM OSPROCESS
primSendSigusr1To: anIntegerPid
	"Send SIGUSR1 (User-defined signal 1) to the OS process identified by anIntegerPid.
	Answer 0 on success, -1 on failure, and nil if the pluggable primitive is not present."

	<primitive: 'primitiveSendSigusr1To' module: 'UnixOSProcessPlugin'>
	^ nil

