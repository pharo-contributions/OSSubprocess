close and dup2
initPosixSpawnFileActionsT
	| returnValue |
	"It seems posix_spawn_file_actions_init sometimes allocates AND initializes, and sometimes only initializes.
	For OSX I found it it also allocates memory, so only allocating for the pointer is enough.
	For Linux it seems we need to allocate the full structure of posix_spawn_file_actions_t.
	Wathing at the implementation of GNU libc (glibc) here: http://osxr.org:8080/glibc/source/posix/spawn.h?v=glibc-2.17 
	I found this struct definition:
	
	typedef struct
	 {
	   int __allocated;
	   int __used;
	   struct __spawn_action *__actions;
	   int __pad[16];
	 } posix_spawn_file_actions_t;
	
	That is how I stimate that in a 32 bits image, such a struct may allocate 76 bytes. 
	We need a better solution to solve this kind of sizeof().
	For more details see thread 'Help with FFI crash in latest Spur (only in Linux)'
	"
	self flag: #fixIt.
	OSPlatform current isMacOSX ifTrue: [ posixSpawnFileActionsT := ExternalAddress allocate: 4. ].
	OSPlatform current isUnix ifTrue: [ posixSpawnFileActionsT := ExternalAddress allocate: 76. ].
	self registerPointer: posixSpawnFileActionsT.
	returnValue := self primitivePosixSpawnFileActionsInit: posixSpawnFileActionsT. 
	returnValue = 0 ifFalse: [ self systemAccessor strerror: returnValue message: 'posix_spawn_file_actions_init()' ].