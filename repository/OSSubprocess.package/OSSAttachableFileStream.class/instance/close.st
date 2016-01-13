open/close
close
	"Close this file."

	| h |
	(h := self basicFileID) ifNotNil: [
		self primCloseNoError: h.
		self unregister.
		fileID := nil
	]
