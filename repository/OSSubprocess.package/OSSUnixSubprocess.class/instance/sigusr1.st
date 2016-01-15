OS signal sending
sigusr1
	"Send a SIGUSR1 signal to the external process represented by self"

	^ self systemAccessor primSendSigusr1To: self pid