examples
stdIn

	"self stdIn"

	^ self name: 'stdIn' attachTo: OSProcess thisOSProcess stdIn ioHandle writable: false
