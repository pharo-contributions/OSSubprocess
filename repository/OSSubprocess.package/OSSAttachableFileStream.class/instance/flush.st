read, write, position
flush
	"Flush the external OS stream (the one in the C library)."
	OSSSystemAccessor current fflush: self getFilePointerAsCFile