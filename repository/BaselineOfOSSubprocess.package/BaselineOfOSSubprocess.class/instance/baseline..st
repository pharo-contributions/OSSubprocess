baseline
baseline: spec
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
				spec repository: 'github://pharo-contributions/pharo-unicode/src' ].

			spec
				group: 'Core' with: #( 'OSSubprocess' );
				group: 'Tests' with: #( 'OSSubprocess-Tests-Unit' 'OSSubprocess-Tests-Stress' ).
		]
