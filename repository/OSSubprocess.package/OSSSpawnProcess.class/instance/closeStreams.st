cleaning
closeStreams
	fileDescriptionsToClose do:[:each |
		self closeFileDescription: each ].	
		

