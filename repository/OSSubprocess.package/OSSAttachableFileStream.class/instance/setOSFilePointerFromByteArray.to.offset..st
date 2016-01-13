private - hacks
setOSFilePointerFromByteArray: externalFilePointer to: aDestByteArray offset: anOffsetNumber
	| filledExternalFilePointer |
	externalFilePointer size < 4 
		ifTrue: [ 
			filledExternalFilePointer := ByteArray new: 4.
			externalFilePointer withIndexDo: [:obj :index| filledExternalFilePointer at: index put: obj ].
		]
		ifFalse: [ filledExternalFilePointer :=  externalFilePointer ].
	1 to: 4 do: [ :index | aDestByteArray at: (index + anOffsetNumber) put: (filledExternalFilePointer at: index) ]
	