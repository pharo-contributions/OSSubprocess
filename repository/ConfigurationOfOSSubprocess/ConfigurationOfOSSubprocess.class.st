"
I am a Configuration of OSSubprocess. 

OSSubprocess is a software project that allows the user to spawn Operating System processes from within Pharo. The main usage of forking external OS processes is to be able to execute OS commands (.e.g cat, ls, ps, cp, etc) as well as arbitrary shell scripts (e.g. /etc/myShellScript.sh) from Pharo.

An important part of OSSubprocess is how to manage standard streams (stdin, stdout and stderr) and how to provide an API for reading and writing from them at the language level.

For more details see: https://github.com/marianopeck/OSSubprocess
"
Class {
	#name : #ConfigurationOfOSSubprocess,
	#superclass : #ConfigurationOf,
	#category : 'ConfigurationOfOSSubprocess'
}

{ #category : #catalog }
ConfigurationOfOSSubprocess class >> catalogChangeLog [
	^ 'See https://github.com/pharo-contributions/OSSubprocess/blob/master/CHANGELOG.md'
]

{ #category : #catalog }
ConfigurationOfOSSubprocess class >> catalogContactInfo [
	^ 'Pharo mailing list'
]

{ #category : #catalog }
ConfigurationOfOSSubprocess class >> catalogDescription [
	^ 'OSSubprocess is a software project that allows the user to spawn Operating System processes from within Pharo. The main usage of forking external OS processes is to be able to execute OS commands (e.g. cat, ls, ps, cp, etc) as well as arbitrary shell scripts (e.g. /etc/myShellScript.sh) from Pharo.

An important part of OSSubprocess is how to manage standard streams (stdin, stdout and stderr) and how to provide an API for reading and writing from them at the language level.

For more details see: https://github.com/pharo-contributions/OSSubprocess'
]

{ #category : #catalog }
ConfigurationOfOSSubprocess class >> catalogKeyClassesAndExample [
	^ ' See https://github.com/pharo-contributions/OSSubprocess/ '
]

{ #category : #catalog }
ConfigurationOfOSSubprocess class >> catalogKeywords [
	^ #(OSProcess forking processes Unix)
]

{ #category : #'symbolic versions' }
ConfigurationOfOSSubprocess >> stable: spec [
	<symbolicVersion: #stable>
	
	spec for: #'pharo7.x' version: '1.0.0'.
	spec for: #'pharo6.x' version: '1.0.0'.
	spec for: #'pharo5.x' version: '0.2.5'
]

{ #category : #versions }
ConfigurationOfOSSubprocess >> v0_1_4: spec [
	<version: '0.1.4'>
	
	spec
		for: #'common'
		do: [ 
			spec
				baseline: 'OSSubprocess'
					with: [ spec repository: 'github://pharo-contributions/OSSubprocess:v0.1.4/repository' ];
				import: 'OSSubprocess' ].
]

{ #category : #versions }
ConfigurationOfOSSubprocess >> v0_2_0: spec [
	<version: '0.2.0'>
	
	spec
		for: #'common'
		do: [ 
			spec
				baseline: 'OSSubprocess'
					with: [ spec repository: 'github://pharo-contributions/OSSubprocess:v0.2.0/repository' ];
				import: 'OSSubprocess' ].
]

{ #category : #versions }
ConfigurationOfOSSubprocess >> v0_2_1: spec [
	<version: '0.2.1'>
	
	spec
		for: #'common'
		do: [ 
			spec
				baseline: 'OSSubprocess'
					with: [ spec repository: 'github://pharo-contributions/OSSubprocess:v0.2.1/repository' ];
				import: 'OSSubprocess' ].
]

{ #category : #versions }
ConfigurationOfOSSubprocess >> v0_2_2: spec [
	<version: '0.2.2'>
	
	spec
		for: #'common'
		do: [ 
			spec
				baseline: 'OSSubprocess'
					with: [ spec repository: 'github://pharo-contributions/OSSubprocess:v0.2.2/repository' ];
				import: 'OSSubprocess' ].
]

{ #category : #versions }
ConfigurationOfOSSubprocess >> v0_2_3: spec [
	<version: '0.2.3'>
	
	spec
		for: #'pharo'
		do: [ 
			spec
				baseline: 'OSSubprocess'
					with: [ spec repository: 'github://pharo-contributions/OSSubprocess:v0.2.3/repository' ];
				import: 'OSSubprocess' ].
]

{ #category : #versions }
ConfigurationOfOSSubprocess >> v0_2_4: spec [
	<version: '0.2.4'>
	
	spec
		for: #'pharo'
		do: [ 
			spec
				baseline: 'OSSubprocess'
					with: [ spec repository: 'github://pharo-contributions/OSSubprocess:v0.2.4/repository' ];
				import: 'OSSubprocess' ].
]

{ #category : #versions }
ConfigurationOfOSSubprocess >> v0_2_5: spec [
	<version: '0.2.5'>
	
	spec
		for: #'pharo'
		do: [ 
			spec
				baseline: 'OSSubprocess'
					with: [ spec repository: 'github://pharo-contributions/OSSubprocess:v0.2.5/repository' ];
				import: 'OSSubprocess' ].
]

{ #category : #versions }
ConfigurationOfOSSubprocess >> v1_0_0: spec [
	<version: '1.0.0'>
	
	spec
		for: #'pharo'
		do: [ 
			spec
				baseline: 'OSSubprocess'
					with: [ spec repository: 'github://pharo-contributions/OSSubprocess:v1.0.0/repository' ];
				import: 'OSSubprocess' ].
]
