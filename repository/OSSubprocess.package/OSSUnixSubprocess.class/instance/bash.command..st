settings
bash: aBashPath command: aBashCommandString
	"Please read comment of #bashCommand:.
	This is the same as bashCommand: but with the addition that the use can define which shell to be used via 'aBasePath' "
	command := aBashPath.
	arguments := Array with: '-c' with: aBashCommandString. 