OS signal sending
sigint
	"Send a SIGINT signal to the external process represented by self"

	^ self systemAccessor primSendSigintTo: self pid