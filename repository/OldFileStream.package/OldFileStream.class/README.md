I'm a deprecated class. 
Since the version 5, Pharo provides a new file streams API that makes the old one based on classes like FileStream or MultiByteBinaryOrTextStream deprecated. 
Pharo 7 makes the next important steps and removes usages of the old API from the kernel.

What you should remember:
- use file references as entry points to file streams 
- DO NOT USE FileStream class
- 'file.txt' asFileReference readStream and similar methods now return an instance of ZnCharacterReadStream instead of MultiByteFileStream
- 'file.txt' asFileReference writeStream and similar methods now return an instance of ZnCharacterWriteStream instead of MultiByteFileStream
- the new API has a clearer separation between binary and text files

1. Basic Files
By default files are binary. Not buffered.

Read UTF-8 text from an existing file
Obsolete code:
FileStream readOnlyFileNamed: '1.txt' do: [ :stream | 
    stream upToEnd ].
New code:
(File named: 'name') readStream.
(File named: 'name') readStreamDo: [ :stream | ‚Ä¶ ].
'1.txt' asFileReference readStreamDo: [ :stream | 
    stream upToEnd ].

2. Encoding
To add encoding, wrap a stream with a corresponding ZnCharacterRead/WriteStream.
‚ÄúReading‚Äù
utf8Encoded := ZnCharacterReadStream on: aBinaryStream encoding: ‚Äòutf8‚Äô.
utf16Encoded := ZnCharacterReadStream on: aBinaryStream encoding: ‚Äòutf16‚Äô.
‚ÄúWriting‚Äù
utf8Encoded := ZnCharacterWriteStream on: aBinaryStream encoding: ‚Äòutf8‚Äô.
utf16Encoded := ZnCharacterWriteStream on: aBinaryStream encoding: ‚Äòutf16‚Äô.

Force creation of a new file and write a UTF-8 text
Obsolete code:
FileStream forceNewFileNamed: '1.txt' do: [ :stream | stream nextPutAll: 'a ‚â† b' ].
New code:
(File named: ‚Äòname‚Äô) writeStream.
(File named: ‚Äòname‚Äô) writeStreamDo: [ :stream | ‚Ä¶ ].
'1.txt' asFileReference ensureDelete; 
    writeStreamDo: [ :stream | stream nextPutAll: 'a ‚â† b' ].

Get all content of existing UTF-8 file
Obsolete code:
(FileStream readOnlyFileNamed: '1.txt') contentsOfEntireFile.
New code:
'1.txt' asFileReference readStream upToEnd.

3. Buffering
To add buffering, wrap a stream with a corresponding ZnBufferedRead/WriteStream.
bufferedReadStream := ZnBufferedReadStream on: aStream.
bufferedWriteStream := ZnBufferedWriteStream on: aStream.
It is in general better to buffer the reading on the binary file and apply the encoding on the buffer in memory than the other way around. See
[file := Smalltalk sourcesFile fullName.
(File named: file) readStreamDo: [ :binaryFile |
(ZnCharacterReadStream on: (ZnBufferedReadStream on: binaryFile) encoding: ‚Äòutf8‚Äô) upToEnd
]] timeToRun. ‚Äú0:00:00:09.288‚Äù
[file := Smalltalk sourcesFile fullName.
(File named: file) readStreamDo: [ :binaryFile |
(ZnBufferedReadStream on: (ZnCharacterReadStream on: binaryFile encoding: ‚Äòutf8‚Äô)) upToEnd
]] timeToRun. ‚Äú0:00:00:14.189‚Äù

The MultiByteFileStream was buffered. If you create a stream using the expression
'file.txt' asFileReference readStream.
then the ZnCharacterReadStream is not created directly on top of the stream but on top of a buffered stream that uses the file stream internally.

If you create a ZnCharacterReadStream directly on the file stream, then the characters from the file are read one by one which may be about ten times slower!
ZnCharacterReadStream on: (File openForReadFileNamed: 'file.txt').

4. File System
By default, file system files are buffered and utf8 encoded to keep backwards compatibility.
‚Äòname‚Äô asFileReference readStreamDo: [ :bufferedUtf8Stream | ‚Ä¶ ].
‚Äòname‚Äô asFileReference writeStreamDo: [ :bufferedUtf8Stream | ‚Ä¶ ].
FileStream also provides access to plain binary files using the #binaryRead/WriteStream messages. Binary streams are buffered by default too.
‚Äòname‚Äô asFileReference binaryReadStreamDo: [ :bufferedBinaryStream | ‚Ä¶ ].
‚Äòname‚Äô asFileReference binaryWriteStreamDo: [ :bufferedBinaryStream | ‚Ä¶ ].
If you want a file with another encoding (to come in the PR https://github.com/pharo-project/pharo/pull/1134), you can specify it while obtaining the stream:
‚Äòname‚Äô asFileReference
    readStreamEncoded: ‚Äòutf16‚Äô
    do: [ :bufferedUtf16Stream | ‚Ä¶ ].
‚Äòname‚Äô asFileReference
    writeStreamEncoded: ‚Äòutf8‚Äô
    do: [ :bufferedUtf16Stream | ‚Ä¶ ].

Force creation of a new file and write binary data into it
Obsolete code:
(FileStream forceNewFileNamed: '1.bin') 
    binary;
    nextPutAll: #[1 2 3].
New code:
'1.bin' asFileReference ensureDelete; 
    binaryWriteStreamDo: [ :stream | stream nextPutAll: #[1 2 3] ].

Read binary data from an existing file
Obsolete code:
(FileStream readOnlyFileNamed: '1.bin') binary; contentsOfEntireFile.
New code:
'1.bin' asFileReference binaryReadStream upToEnd.

Force creation of a new file with a different encoding
Obsolete code:
FileStream forceNewFileNamed: '2.txt' do: [ :stream | 
    stream converter: (TextConverter newForEncoding: 'cp-1250').
    stream nextPutAll: 'P≈ô√≠li≈° ≈ælu≈•ouƒçk√Ω k≈Ø≈à √∫pƒõl ƒè√°belsk√© √≥dy.' ].
New code:
('2.txt' asFileReference) ensureDelete;
    writeStreamEncoded: 'cp-1250' do: [ :stream |
        stream nextPutAll: 'P≈ô√≠li≈° ≈ælu≈•ouƒçk√Ω k≈Ø≈à √∫pƒõl ƒè√°belsk√© √≥dy.' ].

Read encoded text from an existing file
Obsolete code:
FileStream readOnlyFileNamed: '2.txt' do: [ :stream | 
    stream converter: (TextConverter newForEncoding: 'cp-1250').
    stream upToEnd ].
New code:
('2.txt' asFileReference)
    readStreamEncoded: 'cp-1250' do: [ :stream |
        stream upToEnd ].

Write a UTF-8 text to STDOUT
Obsolete code:
FileStream stdout nextPutAll: 'a ‚â† b'; lf.
New code:
(ZnCharacterWriteStream on: Stdio stdout)
    nextPutAll: 'a ‚â† b'; lf;
    flush.

Write CP-1250 encoded text to STDOUT
Obsolete code:
FileStream stdout 
    converter: (TextConverter newForEncoding: 'cp-1250');
    nextPutAll: 'P≈ô√≠li≈° ≈ælu≈•ouƒçk√Ω k≈Ø≈à √∫pƒõl ƒè√°belsk√© √≥dy.'; lf.
New code:
(ZnCharacterWriteStream on: Stdio stdout encoding: 'cp1250')
    nextPutAll: 'P≈ô√≠li≈° ≈ælu≈•ouƒçk√Ω k≈Ø≈à √∫pƒõl ƒè√°belsk√© √≥dy.'; lf;
    flush.

Read a UTF-8 text from STDIN
CAUTION: Following code will stop your VM until an input on STDIN will be provided!
Obsolete code:
FileStream stdin upTo: Character lf.
New code:
(ZnCharacterReadStream on: Stdio stdin) upTo: Character lf.
Write binary data to STDOUT
obsolete code
FileStream stdout 
    binary
    nextPutAll: #[80 104 97 114 111 10 ].
New code:
Stdio stdout 
    nextPutAll: #[80 104 97 114 111 10 ].

Read binary data from STDIN
CAUTION: Following code will stop your VM until an input on STDIN will be provided!
Obsolete code:
FileStream stdin binary upTo: 10.
New code:
Stdio stdin upTo: 10.

Positionable streams
The message #position: always works on the binary level, not on the character level.
'1.txt' asFileReference readStreamDo: [ :stream | 
    stream position: 4.
    stream upToEnd ].
This will lead to an error (ZnInvalidUTF8: Illegal leading byte for UTF-8 encoding) in case of the file created above because we set the position into the middle of a UTF-8 encoded character. To be safe, you need to read the file from the beginning.
'1.txt' asFileReference readStreamDo: [ :stream |
    3 timesRepeat: [ stream next ].
    stream upToEnd.].

5. Line Ending Conventions
If you want to write files following a specific line ending convention, use the ZnNewLineWriterStream.
This stream decorator will transform any line ending (cr, lf, crlf) into a defined line ending.
By default, it chooses the platform line ending convention.
lineWriter := ZnNewLineWriterStream on: aStream.
If you want to choose another line ending convention you can do:
lineWriter forCr.
lineWriter forLf.
lineWriter forCrLf.
lineWriter forPlatformLineEnding.
-------------------------------------------
Old comment:
 
I represent a Stream that accesses a FilePage from a File. One use for my instance is to access larger "virtual Strings" than can be stored contiguously in main memory. I restrict the objects stored and retrieved to be Integers or Characters. An end of file pointer terminates reading; it can be extended by writing past it, or the file can be explicitly truncated.
	
To use the file system for most applications, you typically create a FileStream. This is done by sending a message to a FileDirectory (file:, oldFile:, newFile:, rename:newName:) which creates an instance of me. Accesses to the file are then done via my instance.

*** On DOS, files cannot be shortened!  ***  To overwrite a file with a shorter one, first delete the old file (FileDirectory deleteFilePath: 'Hard Disk:aFolder:dataFolder:foo') or (aFileDirectory deleteFileNamed: 'foo').  Then write your new shorter version.