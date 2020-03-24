shell
loginShellCommand: aShellCommandString
	"This is a simple facility method for the cases when the user wants to use a login shell as the program.
	See comments of shellCommand: for more information."
	self shellCommand: aShellCommandString.
	arguments := Array with: '-l' withAll: arguments.