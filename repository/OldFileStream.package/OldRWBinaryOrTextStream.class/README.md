This package is to support the migration of OSSubProcess to Pharo 9.0 where FileStream has been removed after been deprecated in Pharo 8.0.




A simulation of a FileStream, but living totally in memory.  Hold the contents of a file or web page from the network.  Can then fileIn like a normal FileStream.

Need to be able to switch between binary and text, as a FileStream does, without recopying the whole collection.  Convert to binary upon input and output.  Always keep as text internally.