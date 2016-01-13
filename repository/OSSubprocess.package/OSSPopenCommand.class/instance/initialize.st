initialize - release
initialize
	super initialize.
	"It seems it's more common to execute commands with read mode than write"
	mode := 'r'.
	redirectSdErrToStdOut := false