USING FROM OSPROCESS
primSendSigusr2To: anIntegerPid
	"Send SIGUSR2 (User-defined signal 2) to the OS process identified by anIntegerPid.
	Answer 0 on success, -1 on failure, and nil if the pluggable primitive is not present."

	<primitive: 'primitiveSendSigusr2To' module: 'UnixOSProcessPlugin'>
	^ nil

