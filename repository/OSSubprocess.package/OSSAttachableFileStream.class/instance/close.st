open/close
close
	"Close this file."

	| h |
	(h := self ioHandle) ifNotNil: [
		self primCloseNoError: h.
		self unregister.
		fileID := nil
	]
