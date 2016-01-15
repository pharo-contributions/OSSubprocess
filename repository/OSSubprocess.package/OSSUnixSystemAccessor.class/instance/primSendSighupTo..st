USING FROM OSPROCESS
primSendSighupTo: anIntegerPid
	"Send SIGHUP (hangup) to the OS process identified by anIntegerPid.
	Answer 0 on success, -1 on failure, and nil if the pluggable primitive is not present."

	<primitive: 'primitiveSendSighupTo' module: 'UnixOSProcessPlugin'>
	^ nil

