versions
v0_2_2: spec
	<version: '0.2.2'>
	
	spec
		for: #'common'
		do: [ 
			spec
				baseline: 'OSSubprocess'
					with: [ spec repository: 'github://pharo-contributions/OSSubprocess:v0.2.2/repository' ];
				import: 'OSSubprocess' ].