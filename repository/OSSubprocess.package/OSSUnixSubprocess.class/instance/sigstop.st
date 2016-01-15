OS signal sending
sigstop
	"Send a SIGSTOP signal to the external process represented by self"

	^ self systemAccessor primSendSigstopTo: self pid