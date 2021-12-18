# Forth BBS 2 (1985)

A reconstruction of a historic Forth BBS system.
Not much else is known about it at this time. File timestamps and log comments seem to hint that the BBS was used around 1985 and ran on DOS (which DOS?).

## Goals

 * Get it to run on modern hardware, an emulator or restored hardware that is period correct
 * Document its history
 * Get it online so that it can be used again by enthusiasts (probably via TCP or WebSocket proxy since I don't have a phone line)

## Directory Contents

 * `pristine/` Unchanged source code for historic preservation purposes.
 * `modern/` Work in progress. A modernized version of the source code that someday will run on modern systems or emulators. We're not sure yet.
 * `screens/` The original screen files split and formatted in a way that can be easily viewed on modern systems.

The soon-to-be-working source code can be found in `pristine/FBBS2.fth`

## Resources

 * ["Inside Forth 83" By: Dr. C. H. Ting](http://forth.org/OffeteStore/1003_InsideF83.pdf) - A very detailed introduction to F83 for those of us who learned Forth in the 21st century.

## Run / Build Instructions

Unknown at this time

## Resources

I will add more resources about this package as I find them.

The BBS was originally found here: http://cd.textfiles.com/simtel/simtel20/MSDOS/FORTH/.index.html

The words that follow are a heavily modified copy of the original documentation, converted to Markdown. The original version can be found in `pristine/`

---

**== BEGIN FBBS2 Documentation ==**

# Purpose

FBBS stands for FORTH Bulletin-Board System, and is a
public domain tree-structured system modeled after the
Communi-tree system. The purpose in placing this code in
the public domain is NOT to provide a general-purpose do-all
BBS for free for everyone for every computer, but rather to
provide a basic system with the capability to be expanded in
almost any direction. I will try to answer questions, but
other than that, I can offer little or no free support for
this system.

To those who wish to alter this system and sell it, feel
free to do so. If you make a lot of money and feel a little
guilty, feel free also to send me some royalties.

# General

If you no little or nothing about tree-structured BBS's, I
strongly advise that you spend an hour or two on one of the
communitree boards (they are listed in The Computer Shopper)
to get a feel for what is going on. The basic premise is
that each message in the tree is appended to some other
message (its parent) and may, in turn, have one or more
messages appended to it (its sub-messages). These sub-
messages can have there own sub-messages and so on. The
top-most message in the tree would normally have as its
submessages all the current major topics in the tree. Each
of these topics could have a list of comments about that
topic, and the comments could have comments, etc. etc.

There is one unique message in the Tree, and that is at
the top of the tree. This message is unique in that it has
no parent (i.e. it was not added to another message). When
the Tree is first brought up, the routine `ENTER-TOP` in-
itializes the system and allows you to enter this message.
All other messages in the system are added to this or some
other message using the `ADDTO <msg-name>` command.

# Types of Commands

The commands (or forth lexicons) in this system may be
split into there groups:

1. User commands
2. Sysop commands
3. Internal commands.

The normal user would use only those commands for reading,
indexing, and finding messages. The Sysop commands include
those for message removal, restructuring the tree, and for
disk compaction. To perform these commands, a large set of
internal commands are used, which neither the sysop nor the
user need be concerned about. Programmers can build more
user and/or sysop functions by combining these internal
commands.

Unlike FBBS-1.0, nothing is system dependent as limiting
which functions can be executed has been implemented. This,
**as well as such things as modem interface, are left to the
end user**.

# User Commands

These are few in number and general-purpose in nature to make
using the board as simple as possible.

## READ <msg-name> [date]

This is the most common function, and is rather self-explanatory.
A heading is printed, the body of the message, and a list of any
submessages. The output may be paused by hitting any key, or
terminated by hitting `K`. If a date is supplied, only submessages
on or after that date will be listed.

## BROWSE <msg-name> [date]

This is just like read, except that only the first line of
the message is printed.

## ADDTO <msg-name>

This function is for adding a sub-message to an existing
message. If the directory or the disk is full, an error
message will result. You will be asked to give the message
a name, which may be up to 30 characters in length (longer
names will be truncated). The name may not contain spaces.
After entering the name, all lines typed in will become
part of the message until an empty line is entered. The
only editing provided is back-space. If you wish to embed
blank lines in your message, put a space in the line before
hitting <cr> again. There is no limitation on message
length in this system other than disk capacity.
After entering an empty line, you are back in the regular
mode.

## INDEX <msg-name> [date]

This function provides a method of viewing the structure
of the tree below a certain message. INDEX FBBS (where
FBBS is the top message in the tree) will display the
structure of the entire tree. Each successive level of
comments is indented 2 spaces from its parent.

If a date is supplied, only messages aon or after that
date will be listed.

## HELP

This just prints "try READ HELP" HELP is a sysop-provided
message that may contain all or part of this document.

# Sysop Commands

Again, these are not too complicated or numerous, and may
be extended as needed. I call them sysop commands because it
may not be desired to give the users this much power.

## START

When you start up this system, this command is needed to
load a few variables from disk

## REMOVE <msg-name>

Self-explanatory. Both <msg-name> and any messages
appended to it are removed, and the associated directory
space (but not disk space) is reclaimed. A trap is provided
to prevent removing the top of the tree.

## CRUNCH

This command reclaims any disk space freed via REMOVE. It
is slow, and should not be used when not needed. A star is
printed as each message is crunched.

## MOVE <msg-name> TO <msg-name>

This command allows a message to be reassigned to another
parent, thus allowing you to move a message to a more
appropriate section of the tree if required. All submes-
sages appended to the message are moved also. A common use
would be to move a message to a parent called GOING... prior
to removing it to give users some warning.

## ENTER-TOP

This command is dangerous, as it will wipe the tree clean.
It is to be used only to enter the first message in the tree
(it is a little difficult to use ADDTO when there is nothing
to addto).

## RE-ENTER <msg-name>

Normally, if you enter a message incorrectly, and wish to
change it, you would use REMOVE and ADDTO. If the message
in question had submessages, they would be lost. RE-ENTER
allows you to enter new text for an exiting message without
loosing the submessages. This is particularly useful for
changing the text at the top of the tree.

# Internals:

Use the comments in the source code as a primary reference,
as I may still make some changes. I will try to highlight a few
things here that seem a little obtuse.

## #BLOCKS, DIR, #DIR and TREE

These constants you will likely wish to change. As it
stands, both the source code and the tree data are in the
same file to make development easier. Most users will want
to use a working file as large as possible, generally the
size of one floppy disk on a floppy system. Change `#BLOCKS`
to the capacity of that file (or to the capacity of your
drive system if you are using direct disk-i/o). If you want
to keep the source on line, set DIR to 40, leaving the
first 40 blocks of the file free to hold the code. Other-
wise, set DIR to 0 and be careful.

The rest of the disk is split into two parts, a directory
area and a data area. If either area gets full, the tree
will be able to accept no more data. You should choose `#DIR`
such that both areas fill up at about the same rate. The
best number to use in dependent on the average message size.
I would suggest 2 or 3 directory slots for each 1k of data
area. Since there are about 22 directory slots in a a
block, this will take up 10-15% of the disk and will
generally be enough unless the messages are very short.

The constants `#BYTES` and TREE are calculated automatically
during compile and tell the # of bytes in the data area and
block that that area starts.

# Data structures

Of these there are two. The first is a fixed-length
directory record, and the second is the body of the message.

Each message in the tree is just a simple ascii file, with
the lines ending in CRLF with EOF (26h) marking the end of
the file. Again, there is no real restriction on the size
of the message other then disk space. If you are
perceptive, you may notice this is exactly the same
structure as a CP/M text file. Note that you cannot store
com files in this structure, as they may contain EOF's in
bad places.

The directory record contains the name of the message, a
few useful fields such as usage, date and length, a pointer
to where the text of the message resides, and 3 pointers to
other records to form the tree structure (parent, daughter,
and sister). Note that there are pointers to records. This
means shuffling the records about is a real no-no. As
directory slots become available when messages are removed,
they are kept track of by a linked list with the variable
MT.PTR pointing to the most recently freed slot.
Note also that the 32 bit pointer to the text of the
message is the only direct reference to that message. All
other references should be made thru the directory. This
allows messages to be moved when the disk is being
compacted.

# Tree Structure

**EDITORS NOTE:**
Something is wrong with this section. The bullets are out of
order and the paragraph topic changes without reason. Possible
file corruption? -RC 17-DEC-2021

If you've ever done an `INDEX <msg-name>` the structure of
the tree is obvious. Each message has a parent. The first
sub-message of a message is it's daughter. To achive the
effect of unlimited number of daughters, the daughter can
point to a younger sister. The youngest sist

1. If there is a daughter, it becomes the new message
2. If there is no daughter, put there is a younger sister, it
   becomes the next message.
3. If there are neither go up the tree until a parent with a
   younger sister is found, which will become the next message.
   If no younger sister can be found, return a zero to indicate
   that the tree is exhausted.
4. TUTOR.LBR and HELP.BLK also some documentation files.
5. FBBS Forth based BBS with source. Two revisions.
6. F83 Text and Documentation files collection.
7. Library files A-I (Files used every day are kept on one of)
8. Library files J-P (the above working disks. These are)
9. Library files Q-Z (new to me or I don't have room above.)

Send a SASE for an index list with citations. Include a letter or
a dollar. John A. Peters 121 Santa Rosa Ave, SF, CA 94112:

# CRUNCHing the disk

This is a little bit complicated, but still only three
screens worth of complicated. The idea behind crunching the
disk is to take all the messages and rearrange them but-up
against one another, making all the empty space contiguous
and ready for more messages. This is done by building a
list of each of the currently occupied directory slots
sorted by the address of the message (BUILD-LIST). With

this list, CRUNCH can move each of the messages to the low
end of the file, updating the address pointers on the
fly. After doing all this, we update END.PTR so we can
make use of the space we freed.

# Customization

You may have noticed more than a few things have been left
out of the code, such as bullet-proofing and modem inter-
face. I consider this sort of thing to be system-dependent
and not really all that difficult to program. This code is
the meat of a bbs (in a reasonablly small and digestable
portion), you may season it to your own taste.

If you need some hints, I have ideas (and a little code)
for everything from archival to passwords to multi-tasking
to user-logons.
