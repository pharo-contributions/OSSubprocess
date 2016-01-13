finalization
finalize

	self autoClose
		ifTrue: [[self primCloseNoError: fileID] on: Error do: []]