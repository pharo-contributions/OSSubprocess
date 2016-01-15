OS signal sending
sigquit
	"Send a SIGQUIT signal to the external process represented by self"

	^ self systemAccessor primSendSigquitTo: self pid