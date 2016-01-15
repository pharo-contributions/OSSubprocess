USING FROM OSPROCESS
primSendSigkillTo: anIntegerPid
	"Send SIGKILL (kill, unblockable) to the OS process identified by anIntegerPid.
	Answer 0 on success, -1 on failure, and nil if the pluggable primitive is not present."

	<primitive: 'primitiveSendSigkillTo' module: 'UnixOSProcessPlugin'>
	^ nil

