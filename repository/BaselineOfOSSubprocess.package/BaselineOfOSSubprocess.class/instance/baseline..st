baseline
baseline: spec
	<baseline>
	spec
		for: #common
		do: [ 
			spec
				package: 'OSSubprocess' with: [ spec requires: 'FFICHeaderExtractor' ];
				package: 'OSSubprocess-Tests' with: [ spec requires: 'OSSubprocess' ].
			
			spec project: 'FFICHeaderExtractor' with: [
  				spec
    					className: 'ConfigurationOfFFICHeaderExtractor';
    					version: 'v0.1.0';
    					repository: 'github://marianopeck/FFICHeaderExtractor:master/repository' ]
				]