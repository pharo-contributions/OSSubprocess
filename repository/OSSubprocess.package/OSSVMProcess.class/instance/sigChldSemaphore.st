child watching
sigChldSemaphore
	"Answer the value of sigChldSemaphore"

	^ sigChldSemaphore ifNil: [sigChldSemaphore := self systemAccessor forwardSigChld].
