OS signal sending
sigalrm
	"Send a SIGALRM signal to the external process represented by self"

	^ self systemAccessor primSendSigalrmTo: self pid