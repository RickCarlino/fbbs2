A note to F83 users from John Peters                 119MAY85JAP

Dear F83 BBS interested person,                     May 15, 1985                                                                   

I have gone thru the various disks and versions I have in the library.  The
files on this disk are the best of all.  The BBS was originally obtained by me
from Jeff Wilson in the form of a MVP Forth disk.  I sent a copy of version
0.0 to Tom Belpasso who modified it for F83 and added Virtual I/O so that the
data can be in a separate file.  There is a working version on the disk called
FBBS1.COM.  It works fine with FBBS2.DAT.  However later Jeff sent me version
2.0 of FBBS.  The COM file I have for that version? gives me a "bad load".
That is why I have included a copy of FBBS1.COM as it is the only working
version I have.  This is on top of the old F83 1.0.0, doen not contain any of
my developement tools and requires you to reset VBLK to zero as it was
originally set to 40.

JP

------------

A HAND WRITTEN NOTE ENCLOSED WITH THE DISK from Tom.  15MAY85JAP

Hi John,                                            Jan 12, 1985

Here is the FBBS stuff.  Pack dosen't work.  There is a file that contains the
old FBBS.BBS messages only.  To access that file.

OPEN FBBS.BBS
0 IS VBLK ( Set virtual block )
START ( Reads the setup data )

NOTE: You have to be in the FBBS vocabulary to exicute the above.

Good luck with it.

Please send me SCRPRINT.COM, NDIR.BLK and SDIR.BLK when you get a chance.

Tom Belpasso

------------

LETTER TO TOM BELPASSO                                15MAY85JAP

Dear Tom,                                           May 15, 1985

I am uploading what I have in the library to CL BBS as a Library so it is not
dependant on you to fix what ails it.  I do want you to have the latest
information on it.  When I compile the file FBBS2.BLK on to F83 2.1.2 it has
problems.  I think it might be in the area of Virtual file I/O.  Currently I
have tried both the VIO in the file FBBS2.BLK and the V-I/0 from EZDIR.BLK
which I have in a seprate file.^
