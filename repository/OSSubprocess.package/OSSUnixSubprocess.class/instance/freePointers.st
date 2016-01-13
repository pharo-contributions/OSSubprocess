pointers management
freePointers
	self pointers do: [ :pointer | pointer free ].
	pointers := nil