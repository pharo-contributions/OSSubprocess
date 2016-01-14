# OSSubprocess

Forking OS processes from Pharo language

##Table of Contents


  * [OSSubprocess](#ossubprocess)
    * [Table of Contents](#table-of-contents)
    * [Summary](#summary)
        * [Funding](#funding)
        * [Status](#status)
        * [OSProcess influence](#osprocess-influence)
    * [Installation](#installation)
    * [Introduction to the API](#introduction-to-the-api)
    * [Child exit status](#child-exit-status)
      * [OSSVMProcess and it's child watcher](#ossvmprocess-and-its-child-watcher)
      * [Accessing child status and interpreting it](#accessing-child-status-and-interpreting-it)
    * [Streams management](#streams-management)
      * [Handling pipes within Pharo](#handling-pipes-within-pharo)
      * [Regular files vs pipes](#regular-files-vs-pipes)
      * [Customizing streams creation](#customizing-streams-creation)
      * [Stdin example](#stdin-example)
    * [Synchronism and  how to read streams](#synchronism-and--how-to-read-streams)
      * [Synchronism vs asynchronous runs](#synchronism-vs-asynchronous-runs)
      * [When to process streams](#when-to-process-streams)
      * [Facilities for synchronous calls and streams processing at the end](#facilities-for-synchronous-calls-and-streams-processing-at-the-end)
        * [Semaphore-based SIGCHLD waiting](#semaphore-based-sigchld-waiting)
        * [Delay-based polling waiting](#delay-based-polling-waiting)
        * [Which waiting to use?](#which-waiting-to-use)
    * [Environment variables](#environment-variables)
      * [Setting environment variables](#setting-environment-variables)
      * [Variables are not expanded](#variables-are-not-expanded)
      * [Accessing environment variables](#accessing-environment-variables)
      * [Inherit variables from parent](#inherit-variables-from-parent)
    * [Shell commands](#shell-commands)
    * [Setting working directory](#setting-working-directory)




## Summary

OSSubprocess is a software project that allows the user to spawn Operatying System processes from within Pharo language. The main usage of forking external OS processes is to be able to execute OS commands (.e.g `cat`, `ls`, `ps`, `cp`, etc) as well as arbitrary shell scripts (.e.g `/etc/myShellScript.sh`) from Pharo. 

An important part of OSSubprocess is how to manage standard streams (`stdin`, `stdout` and `stderr`) and how to provide an API for reading and writing from them at the language level. 

#### Funding
This project is carried on by Mariano Martinez Peck and it is sponsored by Pharo Consortium.

#### Status
It was decided together with Pharo Consortium that as a first step, we should concentrate first on making it work on OSX and Unix. If the tool proves to be good and accepted, we could, at a second step, try to add Windows support. 
OSSubprocess is still in an exploring phase and so it might be unstable. Use this tool with that in mind. That being said, all tests are green in the tested platforms.

#### OSProcess influence   
OSSubprocess is highly influenced by a subset of the OSProcess project. There are parts which we even copied and adapted them (OSSPipe, OSSAttachableStream, OSSUnixProcessExitStatus). Other parts, we took them as inspiration (the idea of ThisOSProcess representing the VM process, the child watcher, and many others). In addition, OSSubprocess currently uses some of the OSProcess **plugin** (not OSProcess image side), such as the SIGCHLD handler or the creation of pipes. 

## Installation
**OSSubprocess currently only works in Pharo 5.0 with Spur VM**. Until Pharo 5.0 is released, for OSSubprocess, we recommend to always grab a latest image and VM. You can do that in via command line:

```bash
wget -O- get.pharo.org/alpha+vm | bash
```

Then, from within Pharo, execute the following to install OSSubprocess:

```Smalltalk
Metacello new
 	configuration: 'OSSubprocess';
 	repository: 'github://marianopeck/OSSubprocess:master/repository';
	version: #stable;
	load.
```

> Important: Do not load OSProcess project in the same image of OSSubprocess because the latter won't work. 

## Introduction to the API
OSSubprocess is quite easy to use but depending on the user needs, there are different parts of the API that could be used. We start with a basic example and later we show more complicated scanarios.

```Smalltalk
OSSUnixSubprocess new	
	command: '/bin/ls';
	arguments: #('-la' '/Users');
	redirectStdout;
	runAndWaitOnExitDo: [ :process :outString  |	
		outString inspect 
	]
```

Until we add support for Windows, the entry point will always be OSSUnixSubprocess, which should work in OSX, Linux and others Unix-like. You can read it's class comments for details. 

A subprocess consist of at least a command/binary/program to be executed (in this example `/bin/ls`) plus some optional array of arguments.

The `#command:` could be either the program name (.e.g `ls`) or the full path to the executable (.e.g `/bin/ls`). If the former, then the binary will be searched using `$PATH` variable and may not be found.  

For the `#arguments:` array, each argument must be a different element. In other words, passing `#('-la /Users')` is not correct since those are 2 arguments and hence should be 2 elements of the array. It is also incorrect to not specify `#arguments:` and specify the command like this: `command: '/bin/ls -la /Users'`. OSSubprocess does *not* do any parsing to the command or arguments. If you want to execute a command with a full string like `/bin/ls -la /Users`, you may want to take a look to `#bashCommand:` which relies on shell to do that job.

With `#redirectStdout` we are saying that we want to create a stream and that we want to map it to `stdout` of the child process. Since they are not specified, `stderr` and `stdin` will then be inherit from the parent process (Pharo VM process). If you comment the line of `#redirectStdout` and run the example again, you can see how the output of `/bin/ls -la /Users` is printed in the terminal (where you launched your Pharo image).

Finally, we use the `#runAndWaitOnExitDo:` which is a high level API method that runs the process, waits for it until it finishes, reads and the closes `stdout` stream, and finally invokes the passed closure. In the closure we get as arguments the original `OSSUnixSubprocess` instance we created, and the contents of the read `stdout`. If you inspect `outString` you should see the output of `/bin/ls -la /Users` which should be exactly the same as if run from the command line.

## Child exit status
When you spawn a process in Unix, the new process becomes a "child" of the "parent" process that launched it. In our case, the parent process is the Pharo VM process and the child process would be the one executing the command (in above example, `/bin/ls`). It is a responsability of the parent process to collect the exit status of the child once it finishes. If the parent does not do this, the child becomes a "zombie" process. The exit status is an integer that represents how the child finished (if sucessful, if error, which error, if received a signal, etc etc.). Besides avoiding zombies, the exit status is also important for the user to take actions depending on its result. 

### OSSVMProcess and it's child watcher

In OSSubprocess, we have a class `OSSVMProcess` with a singleton instance accessed via a class side method `vmProcess` which represents the operating system process in which the Pharo VM is currently running. OSSVMProcess can answer some information about the OS process running the VM, such as running PID, children, etc etc. More can be added later. 

Another important task of this class is to keep track of all the launched children processes (instances of `OSSUnixSubprocess`). Whenever a process is started it's registered in OSSVMProcess and unregister in certain scenarios (see senders of ``#unregisterChildProcess:``). We keep a  list of all our children, and ocasionally prune all those that have already been exited. 

This class takes care of running what we call the "child watcher" which is basically a way to monitor children status and collect exit code when they finish. This also guarantees not to let zombies process. As for the implementation details, we use a SIGCHLD handler to capture a child death. For more details, see method `#initializeChildWatcher`.
 
*What is important here is that wether you wait for the process to finish or not (and no matter in which way you wait), the child exit code will be collected and stored in the `exitStatus` instVar of the instance of `OSSUnixSubprocess` representing the exited process, thanks to the `OSSVMProcess` child watcher.* 

### Accessing child status and interpreting it
No matter how you waited for the child process to finish, when it exited, the instVar `exitStatus` should have been set. `exitStatus` is an integer bit field answered by the `wait()` system call that contains information about exit status of the process. The meaning of the bit field varies according to the cause of process exit. Besides understanding `#exitStatus`, `OSSUnixSubprocess` also understands `#exitStatusInterpreter` which answers an instance of `OSSUnixProcessExitStatus`. The task of this class is to simply decode this integer bit field and provide meaningful information. Please read it's class comment for further details. 

In addition to `#exitStatus` and `#exitStatusInterpreter`, `OSSUnixSubprocess` provides testing methods such us `#isSuccess`, `#isComplete`, `isRunning`, etc. 

Let's see a possible usage of the exit status:

```Smalltalk
OSSUnixSubprocess new	
	command: '/bin/ls';
	arguments: #('-la' '/noneexisting');
	redirectStdout;
	redirectStderr;
	runAndWaitOnExitDo: [ :process :outString :errString |	
		process isSuccess 
			ifTrue: [ Transcript show: 'Command exited correctly with output: ', outString. ]
			ifFalse: [ 
				"OSSUnixProcessExitStatus has a nice #printOn: "
				Transcript show: 'Command exit with error status: ', process exitStatusInterpreter printString; cr.
				Transcript show: 'Stderr contents: ', errString.
			] 
	]
```

In this example we are executing `/bin/ls` passing a none existing directory as argument. 

First, note that we added also a stream for `stderr` via `#redirectStderr`. Second, note how now in the `#runAndWaitOnExitDo:` we can also have access to `errString`. If you run this example with a `Transcript` opened, you should see something like:

```
Command exit with error status: normal termination with status 1
Stderr contents: ls: /noneexisting: No such file or directory
```

The `normal termination with status 1` is the information that `OSSUnixProcessExitStatus` (accessed via `#exitStatusInterpreter`) decoded for us. "Normal termination" means it was not signaled or terminated, but rather a normal exit. The exit status bigger than zero (in this case, 1), means error. What each error means depends on the program you run. 
 
The second line of the `Transcript` is simply the `stderr` conents.  


## Streams management
There are many parts of the API and features of OSSubprocess which are related to streams. In this section we will try to explain these topics.

### Handling pipes within Pharo
Besides regular files (as the files you are used to deal with), Unix provides **pipes**. Since Unix manages pipes quite polimorphically to regular files, you can use both for mapping standard streams (`stdin`, `stdout` and `stderr`). That means that both kind of files can be used to communicate a parent and a child process. 

For regular files, Pharo already provides `Stream` classes to write and read from them, such as `StandardFileStream` and subclasses. For pipes things are different becasue there is a write end and a read end (each having a different file descriptor at Unix level). For this purpose, we have implemented the class called `OSSPipe` which represents a OS pipe and it is a subclass of `Stream`. `OSSPipe` contains both, a `reader` and a `writer`, and it implements the `Stream` protocol by delegating messages to one or the other. For example `OSSPipe>>#nextPutAll:` is delegated to the writer while `#next` is delegated to the reader. That way, we have a Stream-like API for pipes. For more details, please read the class comment of `OSSPipe`.

The question is now what type of streams are the 'reader' and 'writer' instVars of a `OSSPipe`. As I said before, the write end and read end of a pipe have different file descriptor at Unix level, hence they are seem as two different file streams. When we create a pipe via a system call, we directly get both file descriptors. That means that in Pharo, once we created a OS pipe, we already have both, the read and the write. Ideally, we could use `StandardFileStream` for this case too. However, those file streams were *already opened* by the system call to make the pipes. To solve this issue, we created what we call `OSSAttachableFileStream` which is a special subclass of `StandardFileStream` and that can be *attached* to an already existing and opened file. 

To conclude, we use a system call to create an OS pipe. At Pharo level we represent that pipe as an instance of `OSSPipe`. And a `OSSPipe` has both, a reader and a writer which are both instances of `OSSAttachableFileStream` and that have been attached to the reader and writer end of the pipe. 

### Regular files vs pipes
As we said before, both regular files or pipes can be used for mapping standard streams (`stdin`, `stdout` and `stderr`) and OSSubprocess supports both and manages them quite polymorphically thanks to `OSSPipe` and `OSSAttachableFileStream`. But the user can decide use one or another. Pipes are normally faster since they run in memory. On the contrary, files may do I/0 operations even with caches (at least creating and deleting the file). With pipes you do not have to handle the deletion of the files as you do with regular files. You can read more about "regular files vs pipes" in the internet and come yourself to a conclusion. 

There is only one problem with pipes that you should be aware of and it's the fact that you may get a deadlock in certain cirtcunstances. See [Semaphore-based SIGCHLD waiting](#semaphore-based-sigchld-waiting) for more details. 

### Customizing streams creation
Let's consider this example:

```Smalltalk
| process |
process := OSSUnixSubprocess new	
			command: '/bin/ls';
			arguments: #('-la' '/noneexisting');
			defaultWriteStreamCreationBlock: [OSSVMProcess vmProcess systemAccessor makeNonBlockingPipe];
			redirectStdout;
			redirectStderrTo: '/tmp/customStderr.txt' asFileReference writeStream;
			defaultReadStreamCreationBlock: [ process createTempFileToBeUsedAsReadStreamOn: '/tmp' ];
			createMissingStandardStreams: true.	
Halt halt.			
process runAndWait.  
process isSuccess 
	ifTrue: [ Transcript show: 'Command exited correctly with output: ', process stdoutStream upToEnd. ]
	ifFalse: [ 
		"OSSUnixProcessExitStatus has a nice #printOn: "
		Transcript show: 'Command exit with error status: ', process exitStatusInterpreter printString; cr.
		Transcript show: 'Stderr contents: ', process stderrStream upToEnd.
	].
process closeAndCleanStreams.
```

There are many things to explain in this example. First of all, we are not using the API `#runAndWaitOnExitDo:` and so certain things must be done manually (like retrieving the contents of the streams via `#upToEnd` or like closing and cleaning streams with `#closeAndCleanStreams`). Now you get a better idea of what `#runAndWaitOnExitDo:` does automatically for you. The reason we are not using `#runAndWaitOnExitDo:` and instead the low level API, is to have a `Halt halt` while running the process so that you can confirm yourself the existance of the files used for the streans, as explained next. 

With the methods `#redirectStdinTo:`, `#redirectStdoutTo:` and `#redirectStdoutTo:` the user is able to set a custom stream for each standard stream. The received stream could be either a `StandardFileStream` subclass (as is the result of `'/tmp/customStderr.txt' asFileReference writeStream`) or a `OSSPipe` (as is the result of `OSSVMProcess vmProcess systemAccessor makeNonBlockingPipe`).

If you do not want to create a custom stream (like above example of `#redirectStderrTo:`) but you still want to create a default stream that would be mapped to a standard stream, then you can use the methods `#redirectStdin:`, `#redirectStdout` and `#redirectStderr`. Those methods will create *default* streams. The *default* streams are defined by the instVars `defaultWriteStreamCreationBlock` and `defaultReadStreamCreationBlock`. And these can be customized too as shown in above example. In this example, all write streams (to be used for `stdout` and `stderr`) will be pipes (forget for the moment about the none blocking part). And all read streams (only used by `stdin`) will be temp files automatically created in `/tmp`. This feature is useful if you want to change the way streams are created without having to specially create each stream. You can see how `OSSPipeBasedUnixSubprocessTest` and `OSSFileBasedUnixSubprocessTest` use these in the method `#newCommand`. 

*If you see `OSSUnixSubprocess>>#initialize` you will see that by default we create pipes for all type of streams.* 

Previously, we said that if the user does not specify a stream to be mapped to one of the standard streams (by any of the means explained above), the child will inherit the one of the parent process (VM Process). With the method `#createMissingStandardStreams:` one can change that behavior, and instead, create default streams for all none already defined streams. In above example, the user defined `stdout` via `#redirectStdout` and `stderr` via `#redirectStderrTo:`. So, by doing `#createMissingStandardStreams: true`, a default stream (pipe) will be created and mapped to the missing streams (only `stdin` in this example). Of course, if you are happy with default streams creation, you can avoid having to declare each stream and simple enable all. But keep in mind the costs of managing streams that you may not use at all. For this reason, the default value of `createMissingStandardStreams` is `false`.

Finally, note that since we are not using the API `#runAndWaitOnExitDo:` in this case, we must explicitly close streams via the message `#closeAndCleanStreams`. This method will also take care of deleting all those streams which were regular files (not pipes). 


### Stdin example
All of the examples so far showed how to redirect `stdout` and `stderr`. Below is an example on how can we redirect `stdin` and write to it from Pharo:

```Smalltalk
| process |
process := OSSUnixSubprocess new	
				command: '/bin/cat';
				redirectStdin;
				redirectStdout;
				run. 
process stdinStream 
		nextPutAll: 'we are testing!';
		nextPutAll: 'we again!';
		close.		
process waitForExit.
process stdoutStream upToEnd inspect. 
process closeAndCleanStreams.
```

If you run above example you will see how the strings are first written to the `stdin` of the child process and then the child writes them to `stdout` (that's what the `cat` command does). We finally read them from `stdout`.  

Note that the `#close` we send to the `stdinStream` is very important. This is because by default, we use blocking pipes for `stdin` and that means that when the child tries to read he will be locked until data is available. Therefore, somehow, at some point, we must tell the child that we have finished writing and that is via the `#close` message. 
		



## Synchronism and  how to read streams 


###  Synchronism vs asynchronous runs 
We call synchronous runs when you create a child process and you wait for it to finish before going to the next task of your code. This is by far the most common approach since many times you need to know which was the exit status (wether it was success or not) and depending on that, do something. 

Asynchronous runs are when you run a process and you do not care it's results for the next task of your code. In other words, your code can continue its execution no matter what happened with the spawned process. For this scenario, we currently do not support any special facility, althought it is planned. If you would be interested in this functionallity, please contact me.  

### When to process streams
If we have defined that we wanted to map a standard stream, it means that at some point we would like to read/write it and **do something with it**. 
There are basically two possibilities here. The most common approach is to simply wait until the process has finished, and once finished, depending on the exit status, **do something** with the stream contents. What to do exactly, depends on the needs the user has for that process.

The other possibility a user may do, is to define some code that loops while the process is still running. For every cycle of the loop, it retrieves what is available from the streams and do something with it. But in this case, **doing something** is not simply accumulating the stream contents in another stream so that it is processed at the end. By doing something we really mean that the user wants to do something with that intermediate result: print it in a `Transcript`, show a progress bar, or whatever.  

If what you need is the second possibility then you will have to write your custom loop code. You can take a look to `#waitForExitPollingEvery:retrievingStreams:` and `#runAndWaitPollingEvery:retrievingStreams:onExitDo:`


### Facilities for synchronous calls and streams processing at the end
For synchronous calls in which streams processing could be done once the process has exited, we provide some facilities methods that should ease the usage. Synchronous calls mean that we must wait for the child to exit. We provide two ways of doing this. 

#### Semaphore-based SIGCHLD waiting 
The first way is with the method `#waitForExit`. This method is used by the high level API methods `#runAndWait` and `#runAndWaitOnExitDo:`. The wait in this scenario does **not** use an image-based delay polling. Instead, it uses a semaphore. Just after the process starts, it waits on a semaphore of the instVar `mutexForSigchld`. When the `OSSVMProcess` child watcher receives a `SIGCHLD` singal, it will notify the child that die with the message `#processHasExitNotification`. That method, will do the `#signal` in the semaphore and hence the execution of `#waitForExit` will continue.

> **IMPORTANT** In this kind of waiting there is no polling and hence we do not read from the streams periodically. Instead, we read the whole contents of each stream at the end. Basically, there is a problem in general (deadlock!) with waiting for an external process to exit before reading its output. If the external process creates a large amount of output, and if the output is a pipe, it will block on writing to the pipe until someone (our VM process) reads some data from the pipe to make room for the writing. That leads to cases where we never read the output (because the external process did not exit) and the external process never exits (because we have not read the data from the pipe to make room for the writing).

> Another point to take into account is that this kind of wait also depends on the child watcher and `SIGCHLD` capture. While we do our best to make this as reliable as possible, it might be cases where we miss some `SIGCHLD` signals. There is a workaround for that (see method `#initializeChildWatcher`), but there may still be issues. If such problem happens, the child process (at our language level) never exits from the `#waitForExit` method. And at the OS level, the child would look like a zombie becasue the parent did not collect the exit status. 

#### Delay-based polling waiting
The other way we have for waiting a child process is by doing a delay-based in-image polling. That basically means a loop in which we wait some miliseconds, and then check the exit status of the process. For this, we provide the method `#waitForExitPollingEvery:retrievingStreams:`, and it's high level API method `#runAndWaitPollingEvery:retrievingStreams:onExitDo:`.

It is important to note that as part of the loop we send `#queryExitStatus`, which is the one that sends the `waitpid()` in Unix. That means that we are fully independent of the child watcher and the `SIGCHLD` and hence much more reliable than the previous approach.

In addition, we provide a `retrievingStreams:` boolean which if true, it reads from streams as part of the loop. This solves the problem mentioned before where there could be a deadlock if there is no room in the pipe for the writing. 

Below is an example of delay polling:

```Smalltalk
OSSUnixSubprocess new	
	command: '/bin/ls';
	arguments: #('-la' '/Users');
	redirectStdout;
	runAndWaitPollingEvery: (Delay forMilliseconds: 50) retrievingStreams: true onExitDo: [ 
		:process :outString  |	
		outString inspect 
	]
```


Of course, the main disadvantage of the polling is the cost of it at the language level. The waiting on a semaphore (as with the `SIGCHLD`) has no cost.  

#### Which waiting to use?
If you are using pipes and you are not sure about how much the child process could write in the streams, then we recommend the polling approach (with `retrievingStreams:` with `true`). 

If you are using pipes and you know the process will not write much, then you can use both approaches. If you want to be sure 100% to never ever get a zombie or related problem, then we think the polling approach is a bit more reliable. If you can live with such a possibility, then maybe the `SIGCHLD` approach could work too. 

If you are using files instead of pipes, then it would depend on how long does the process take. If it is normally short, then the polling approach would be fine. If it is a long process then you may want to do the `SIGCHLD` approach to avoid the polling costs. But you can also use the polling approach and specify a larger timeout. 

*As you can see, there is no silver bullet. It's up to the user to know which model would fit better for his use-case. If you are uncertain or you are not an expert, then go with the polling approach with `retrievingStreams:` on `true`.*


## Environment variables

### Setting environment variables

One common requirement for child processes is to define environment variables for them, that may not even exist in the parent process. Let's see an example:

```Smalltalk
OSSUnixSubprocess new	
	command: '/usr/bin/git';
	arguments: #('-C' '/Users/mariano/git/OSSubprocess' 'commit');
	environmentAt: 'GIT_EDITOR' put: '/Users/mariano/bin/mate';
	redirectStdout;
	runAndWaitOnExitDo: [ :process :outString  |]
```

In this example we are executing `/usr/bin/git` and we are telling it to commit from the directory `/Users/mariano/git/OSSubprocess`. Without any particular environment variable setting, `git` will use the default editor. In my machine, it will use `nano` editor. However, in above example, we are setting a environment variable called `GIT_EDITOR` (which is *not* set in parent process) with the value `/Users/mariano/bin/mate` (TextMate editor for OSX). When we run this example, `git` will then use TextMate for entering the commit message instead of `nano`. 

### Variables are not expanded
You should not confuse the above example with variables expansions. Consider now this example:

```Smalltalk
OSSUnixSubprocess new	
	command: '/bin/echo';
	arguments: #('${HOME}');
	environmentAt: 'HOME' put: 'hello';
	redirectStdout;
	runAndWaitOnExitDo: [ :command :outString |
		outString inspect
	].
```

What do you expect to be the `outString`? Well, the answer is the literal string `${HOME}`. This is because OSSubprocess does *not* expands variables. It does *set* variables, but that's not the same as expanding them. 

Variable expansion is a responsibility of the shell, not of the command. Specific commands will of course consult their environment, but only for variables that they are designed to use (e.g. `git` will use $GIT_EDITOR or fall back to $EDITOR when you have to type a commit message). 

To conclude this topic, see this example:

```Smalltalk
OSSUnixSubprocess new	
	command: '/bin/sh';
	arguments: #('-c' 'echo ${HOME}');
	environmentAt: 'HOME' put: 'hello';
	redirectStdout;
	runAndWaitOnExitDo: [ :command :outString |
		outString inspect. 	
	].
```

In this case, the `outString` is indeed `hello` and this is simply because `/bin/sh` did the variable expansion before executing the `echo`.


### Accessing environment variables
It seems some people use OSProcess (or maybe even OSSubprocess) to access environment variables. **This is not needed and it's not the best approach**. Pharo provides an out of the box way for accessing environment variables. For example, `Smalltalk platform environment at: 'PWD'` answers `/Users/mariano/Pharo/imagenes`. So, use that API for retrieving environment variables.

Finally, not that you can "expand" yourself the value of a variable prior to spawing a process and hence avoid the need of the shell. example:

```Smalltalk
OSSUnixSubprocess new	
	command: '/bin/echo';
	arguments: (Array with: (Smalltalk platform environment at: 'HOME'));
	redirectStdout;
	runAndWaitOnExitDo: [ :command :outString |
		outString inspect
	].
```

In this example, `outString` will be `/Users/mariano`.  
 

### Inherit variables from parent
If you don't define any variable via `#environmentAt:put:`, then by default, we will make the child process inherit all the variables from the parent process. If you did define at least one variable, then by default the child inherits no variable. However, you have the method `#addAllEnvVariablesFromParentWithoutOverride` which basically adds all the variables inherit from the parent but those that you have explicitly set (if any). 



## Shell commands
Sometimes, the process you want to execute is a shell. There are a couple of reasons for doing so:

* Variables expansion.
* Pipelines.
* When there is already logic in `.bash_profile`, `.profile` or such kind of file.
* Command path resolution.
* Streams redirection.
* Available shell scripts that you want to execute.
* Convinience when you don't need to have full control.

Quite some of that list can easily be done without the need of a shell, as already explained. But some of them, still need the shell. To avoid having to invoke a shell as seen in XXX, we provide the methods `#shellCommand:` and `#shell:command:`. Example:

```Smalltalk
OSSUnixSubprocess new	
	shellCommand: 'ps -fea | grep Pharo > /tmp/testShellCommandWithStreamRedirects.deleteme';
	redirectStdout;
	runAndWaitOnExitDo: [ :command :outString |
		outString inspect. 					
	].
```

Of course, `outString` is empty now becasue the shell has redirected it to a particular file. 

`#shell:command:` is similar to `#shellCommand:` but allows the user to specify the full path of the shell to use. 

> Note that when using the shell you must type the command exactly as the shell expects it, that is, with all the scaping and everything needed.


## Setting working directory 
Another common need when spawing processes is to set a working directory (`PWD`) for them. If none is set, by default, they inherit the working directory of the parent. Imagine the Pharo image was launched from a terminal while `PWD` was `/Users/mariano`. Now imagine I want to spawn a process for a git commit for the directory `/Users/mariano/git/OSSubprocess`. For this to work, I must specify the working directory for the child. Otherwise, the `commit` will be triggered in `/Users/mariano`. 

To support this, we provide the method `#pwd:` as this example shows:

```Smalltalk
OSSUnixSubprocess new	
	command: '/usr/bin/git';
	arguments: #('commit' '-m' 'testing');
	pwd: '/Users/mariano/git/OSSubprocess';
	redirectStdout;
	redirectStderr;
	runAndWaitOnExitDo: [ :process :outString :errString |
		errString inspect.
		outString inspect. 
		]
```

> The implementation of `#pwd:` is quite rudementary and bad from performance point of view (read the method comment for details). If the program you are executing allows you to specify the path, then we recommend you to do so. For example, in this case, `git` allow us to specify the path with the argument `-C`. That approach would be better, as shown in XXX.











