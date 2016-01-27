versions
developmentVersion: spec
	<version: 'developmentVersion'>
	
	spec
		for: #'common'
		do: [ 
			spec
				baseline: 'OSSubprocess'
					with: [ spec repository: 'github://marianopeck/OSSubprocess:master/repository' ];
				import: 'OSSubprocess' ].