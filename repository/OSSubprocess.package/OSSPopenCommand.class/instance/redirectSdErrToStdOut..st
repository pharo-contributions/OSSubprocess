settings
redirectSdErrToStdOut: aBoolean
	"popen() allows only either stdin or stdout, but not stderr. So if you also need stderr
	you can eithe redirect that to a separate file or to redicect it to the stdOut so that to 
	get it directly in the returned stream"
	redirectSdErrToStdOut := aBoolean