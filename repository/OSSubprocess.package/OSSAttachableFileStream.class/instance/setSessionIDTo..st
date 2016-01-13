private - hacks
setSessionIDTo: fileIDByteArray
	| currentSession |
	currentSession := OSSVMProcess vmProcess sessionID.
	1 to: currentSession size do: [ :index | fileIDByteArray at: index put: (currentSession at: index) ]