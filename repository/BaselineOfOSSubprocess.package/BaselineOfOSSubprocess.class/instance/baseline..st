baseline
baseline: spec
	<baseline>
	spec
		for: #pharo
		do: [ 
			spec preLoadDoIt: #initializeForPharo.	
				
			spec
				package: 'OSSubprocess' with: [ spec requires: 'FFICHeaderExtractor' ];
				package: 'OSSubprocess-Tests-Unit' with: [ spec requires: 'OSSubprocess-Tests-Unit' ];
				package: 'OSSubprocess-Tests-Stress' with: [ spec requires: 'OSSubprocess' ].
			
			spec baseline: 'FFICHeaderExtractor' with: [
    			spec repository: 'github://marianopeck/FFICHeaderExtractor:master/repository' ]
		]