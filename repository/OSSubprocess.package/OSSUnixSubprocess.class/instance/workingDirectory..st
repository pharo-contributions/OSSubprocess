settings
workingDirectory: aString
	"This is a setting that allows defining a working directory for the OS process once started."
	"Working directory is not encoded when set because it is used as FileReference at some places.
	Instead, we encode it in #lockCwdWithValue:encoding:during:"
	workingDirectory := aString