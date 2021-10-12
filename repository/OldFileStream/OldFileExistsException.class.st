"
Notify when file exists
"
Class {
	#name : #OldFileExistsException,
	#superclass : #FileException,
	#instVars : [
		'fileClass'
	],
	#category : 'OldFileStream-Exceptions'
}

{ #category : #exceptioninstantiator }
OldFileExistsException class >> fileName: aFileName fileClass: aClass [ 
	^ self new
		fileName: aFileName;
		fileClass: aClass
]

{ #category : #deprecation }
OldFileExistsException class >> isDeprecated [
	^true
]

{ #category : #exceptiondescription }
OldFileExistsException >> defaultAction [
	"The default action taken if the exception is signaled."

	^ UIManager default fileExistsDefaultAction: self

]

{ #category : #accessing }
OldFileExistsException >> file [
	
	^ self fileClass fileNamed: fileName
]

{ #category : #accessing }
OldFileExistsException >> fileClass [
	^ fileClass ifNil: [OldStandardFileStream]
]

{ #category : #accessing }
OldFileExistsException >> fileClass: aClass [
	fileClass := aClass
]
