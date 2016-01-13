shell
shellCommand: aShellCommandString
	"This is a simple facility method for the cases when the user wants to use shell as the program.
	This way, the user can directly send shellCommand: 'ls -la | grep Pharo > /tmp/test.txt ' with the whole string 
	rather than having to do set the command sh, send the '-c' argument, etc etc etc"
	command := '/bin/sh'.
	arguments := Array with: '-c' with: aShellCommandString. 