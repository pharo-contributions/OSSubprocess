updating
updateFromNewSession
	childWatcher ifNotNil: [ 
		childWatcher terminate.
		childWatcher := nil.
	].
	sigChldSemaphore ifNotNil: [
		self systemAccessor restoreSigChld.
		sigChldSemaphore := nil
	]
