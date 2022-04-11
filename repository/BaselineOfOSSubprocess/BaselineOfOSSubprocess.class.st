"
I am a baseline of OSSubprocess. 

OSSubprocess is a software project that allows the user to spawn Operatying System processes from within Pharo language. The main usage of forking external OS processes is to be able to execute OS commands (.e.g cat, ls, ps, cp, etc) as well as arbitrary shell scripts (.e.g /etc/myShellScript.sh) from Pharo.

An important part of OSSubprocess is how to manage standard streams (stdin, stdout and stderr) and how to provide an API for reading and writing from them at the language level.

For more details see: https://github.com/marianopeck/OSSubprocess
"
Class {
	#name : #BaselineOfOSSubprocess,
	#superclass : #BaselineOf,
	#category : #BaselineOfOSSubprocess
}

{ #category : #baseline }
BaselineOfOSSubprocess >> baseline: spec [
	<baseline>
	spec
		for: #pharo
		do: [				
			spec
				package: 'OldFileStream';
				package: 'OSSubprocess' with: [ spec requires: #('FFICHeaderExtractor' 'OldFileStream') ];
				package: 'OSSubprocess-Tests-Unit' with: [ spec requires: #('OSSubprocess' 'Unicode') ];
				package: 'OSSubprocess-Tests-Stress' with: [ spec requires: 'OSSubprocess-Tests-Unit' ].

			spec baseline: 'FFICHeaderExtractor' with: [
    			spec repository: 'github://pharo-contributions/FFICHeaderExtractor:v1.0.2/repository' ].

			spec baseline: 'Unicode' with: [
				spec repository: 'github://pharo-contributions/pharo-unicode:v1.1.0/src' ].

			spec
				group: 'Core' with: #( 'OSSubprocess' );
				group: 'Tests' with: #( 'OSSubprocess-Tests-Unit' 'OSSubprocess-Tests-Stress' ).
		]

]
