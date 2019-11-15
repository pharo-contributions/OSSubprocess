baseline
baseline: spec
	<baseline>
	spec
		for: #pharo
		do: [ 
			spec preLoadDoIt: #initializeForPharo.	
				
			spec
				package: 'OSSubprocess' with: [ spec requires: 'FFICHeaderExtractor' ];
				package: 'OSSubprocess-Tests-Unit' with: [ spec requires: #('OSSubprocess' 'Unicode') ];
				package: 'OSSubprocess-Tests-Stress' with: [ spec requires: 'OSSubprocess-Tests-Unit' ].
			
			spec baseline: 'FFICHeaderExtractor' with: [
    			spec repository: 'github://marianopeck/FFICHeaderExtractor:master/repository' ].
		
			spec project: 'Unicode' with: [
				spec
					className: #ConfigurationOfUnicode;
					versionString: #'stable';
					repository: 'http://smalltalkhub.com/mc/Pharo/Unicode/main/' ].
			
			spec
				group: 'Core' with: #( 'OSSubprocess' );
				group: 'Tests' with: #( 'OSSubprocess-Tests-Unit' 'OSSubprocess-Tests-Stress' ).
		]
