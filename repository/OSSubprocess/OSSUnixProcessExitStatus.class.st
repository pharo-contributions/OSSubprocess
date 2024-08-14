"
A OSSUnixProcessExitStatus represents the exit status of a unix process. This is an integer bit field answered by the wait() system call that contains information about exit status of the process. The meaning of the bit field varies according to the cause of process exit. 

When the OS process of a OSSUnixSubprocess exits and we collect the exit status via (#queryExitStatus which ends up doing the waitpid()), we get this bit integer bit fields. 
OSSUnixSubprocess #exitStatus answers this integer. To interpret it's result better, then we use this class OSSUnixProcessExitStatus (via #exitStatusInterpreter).
 
Ideally, we should take the resulting integer and call the macros WIFSIGNALED, WIFEXITED etc.. but since they are macros, they are not accessible via FFI. Therefore, we do the internal bit shits ourselves.

However, OSSUnixProcessExitStatus decodes the process exit status in a manner compatible with a typical GNU unix implementation. It is not guaranteed to be portable and may produce misleading results on other unix systems.

Following a normal process exit, the status may be decoded to provide a small positive integer value in the range 0 - 255, which is the value that is presented by a unix shell as the exit status of a program. If terminated by a signal, the corresponding value is the signal number of the signal that caused process exit.


"
Class {
	#name : 'OSSUnixProcessExitStatus',
	#superclass : 'Object',
	#instVars : [
		'intValue'
	],
	#category : 'OSSubprocess',
	#package : 'OSSubprocess'
}

{ #category : 'instance creation' }
OSSUnixProcessExitStatus class >> for: integerValue [

	^self new for: integerValue

]

{ #category : 'accessing' }
OSSUnixProcessExitStatus >> exitStatus [
	
	self isExited ifTrue: [^self statusIfExited].
	self isSignaled ifTrue: [^self statusIfSignaled].
	self isStopped ifTrue: [^self statusIfStopped].
	self notify: 'cannot decode exit status ', intValue asString.
	^intValue
]

{ #category : 'initialize-release' }
OSSUnixProcessExitStatus >> for: anInteger [
	intValue := anInteger
]

{ #category : 'testing' }
OSSUnixProcessExitStatus >> isExited [
	"
	/* Nonzero if STATUS indicates normal termination.  */
	#define __WIFEXITED(status)     (__WTERMSIG(status) == 0)
	"
	^ self statusIfSignaled = 0


]

{ #category : 'testing' }
OSSUnixProcessExitStatus >> isSignaled [
	"
	/* Nonzero if STATUS indicates termination by a signal.  */
	#define __WIFSIGNALED(status) \
	  (((signed char) (((status) & 0x7f) + 1) >> 1) > 0)
	"
	^(((intValue bitAnd: 16r7F) + 1) >> 1) > 0


]

{ #category : 'testing' }
OSSUnixProcessExitStatus >> isStopped [
	"
	/* Nonzero if STATUS indicates the child is stopped.  */
	#define __WIFSTOPPED(status)    (((status) & 0xff) == 0x7f)
	"
	^(intValue bitAnd: 16rFF) = 16r7F


]

{ #category : 'testing' }
OSSUnixProcessExitStatus >> isSuccess [
	^ self exitStatus = 0
]

{ #category : 'testing' }
OSSUnixProcessExitStatus >> notFinished [
	
	^ intValue isNil

]

{ #category : 'printing' }
OSSUnixProcessExitStatus >> printOn: aStream [

	self notFinished
		ifTrue: [^ aStream nextPutAll: 'Not finished'].
	self isExited
		ifTrue: [aStream nextPutAll: 'normal termination with status ';
				 nextPutAll: self statusIfExited asString].
	self isSignaled
		ifTrue: [aStream nextPutAll: 'exit due to signal ';
				nextPutAll: self statusIfSignaled asString].
	self isStopped
		ifTrue: [aStream nextPutAll: 'stopped due to signal ';
				nextPutAll: self statusIfStopped].
]

{ #category : 'accessing' }
OSSUnixProcessExitStatus >> statusIfExited [
	"
	/* If WIFEXITED(STATUS), the low-order 8 bits of the status.  */
	#define __WEXITSTATUS(status)   (((status) & 0xff00) >> 8)
	"
	^(intValue bitAnd: 16rFF00) >> 8
]

{ #category : 'accessing' }
OSSUnixProcessExitStatus >> statusIfSignaled [
	"
	/* If WIFSIGNALED(STATUS), the terminating signal.  */
	#define __WTERMSIG(status)      ((status) & 0x7f)
	"
	^intValue bitAnd: 16r7F
]

{ #category : 'accessing' }
OSSUnixProcessExitStatus >> statusIfStopped [
	"
	/* If WIFSTOPPED(STATUS), the signal that stopped the child.  */
	#define __WSTOPSIG(status)      __WEXITSTATUS(status)
	"
	^self statusIfExited
]

{ #category : 'accessing' }
OSSUnixProcessExitStatus >> statusNotFinished [

	^ 'Not finished'
]

{ #category : 'accessing' }
OSSUnixProcessExitStatus >> value [
	^intValue
]
