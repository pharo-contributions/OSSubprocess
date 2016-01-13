read, write, position
flush
	"Flush the external OS stream (the one in the C library)."

	self primitiveFflush: self getFilePointerAsCFile