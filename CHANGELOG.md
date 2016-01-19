# Change Log



## [v0.1.5](https://github.com/marianopeck/OSSubprocess/tree/v0.1.5) (2016-01-XX)


**Implemented enhancements:**

- Improve `#bashCommand` to rely on $SHELL if defined  [\#13](https://github.com/marianopeck/OSSubprocess/issues/13)
- Add OS signal sending to process (`sigterm`, `sigkill`, etc) [\#4](https://github.com/marianopeck/OSSubprocess/issues/4)
- Added API for processing streams while process is running (`#runAndWaitPollingEvery:doing:onExitDo:`)
- Added option `#terminateOnShutdown` to terminate running processes on Pharo shutdown
- Move creation of temp files to class side

**Fixed bugs:**

- VM Crash when forking infinitive process and image restart (added new `#stopWaiting` called from `#shutDown:`)  [\#12](https://github.com/marianopeck/OSSubprocess/issues/12)

**Closed issues:**

- Double check `ExternalAddress allocate`  and `free` [\#9](https://github.com/marianopeck/OSSubprocess/issues/9)

**Merged pull requests:**

- typos, small edits in first 200 lines [\#1](https://github.com/marianopeck/OSSubprocess/pull/1) ([StephanEggermont](https://github.com/StephanEggermont))

**Documentation updates**

- Better explanation of synchronism vs asynchronous
- Add a section specially for asynchronous with a `tail -f` example
- Add new doc for all new features and enchacements
- Added a ChangeLog file to doc.

[Full Changelog](https://github.com/marianopeck/OSSubprocess/compare/v0.1.4...v0.1.5)


## [v0.1.4](https://github.com/marianopeck/OSSubprocess/tree/v0.1.4) (2016-01-14)
First milestone release.

