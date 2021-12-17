FORTH Bulletin Board, with data in a separate file.   15MAY85JAP
You can run the BBS from your keyboard.  "Screen 31   EXPERIMENT
must be modified for your system to pack the data."
  The orginal concept execution and code is Jeff's.  I started
the conversion from MVP to F83, but Tom actually succeded.  You
may see my initials on the ID date but let me assure you it is
Jeffs progrm.
                         John Peters, F83 Disk Librarian
                            (415) 239-5393 after 7 pm.

  Jeff Wilson  WA2KCM           Tom Belpasso
  55 Bedford Ave.               852-116 Minnesota Avenue
  Bergenfield NJ 07621          San Jose, CA 95125
  (201) 384-1596  MVP version   (408) 292-0352  LP F-83 version


\ Load screen for FORTH BBS               26nov84tjb  15MAY85JAP
 15 VIEWS FBBS2.BLK    .( LOADING )  FILE? CR
: GOODBYE  BYE ;
   3 4 THRU     \  5 6 THRU  \ Virtual I/O
  7 25 THRU
  S-S FBBS2.COM   EXIT
\ 26 36 THRU  EXIT  data packing  ( SYSCALL is undefined JP)
To begin the BBS type:   INIT-BBS which is the same as below.
  OPEN FBBS2.DAT    FBBS   0 IS VBLK   and  START or SAFER
Safer allows only BBS commands, and protects the system from the
user.  Type TPEE to return to Forth.  Type READ BBS to start at
the trunk of the tree.  READ HELP or READ COMMANDS are good too.
See also: STOP PACK INPORT EXPORT REMOVE MOVETO
   When I compile FBBS2.BLK and start it FIND-NAME never does!,
however there is a working version called FBBS1.COM on this disk
that runs on top of F83 1.0.0
\ mods to F83-FORTH version               08dec84tjb  15MAY85JAP

 1) The first block of the virtual memory is the value of  the
    constant VBLK.  Default value is 40 to allow both the source
    and BBS to reside in the same file to facilitate debuging.
    You can dedicate a seperate file for the BBS messages by
    changing the value of VBLK to 0.  I added a double precision
    constant VOFF to allow greater flexablity for the virtual
    memory support.
 2) K? is now case and control key insensitive, ie. upper, lower
    or control K will kill the message.  The same for S to pause
 3) Pack, import and export are untested and not loaded with OK.
                                                            TOM
    P! and P@ changed to PC! and PC@ in this file.
    I am unable to compile a working system on F83 2.1.2   JP

\ LIST OF WORDS KNOT KNOWN BY LP-83 2.1.0             15MAY85JAP
 ONLY FORTH ALSO
VOCABULARY FBBS  FBBS DEFINITIONS ALSO
: OPENFILE   [ DOS ] OPEN-FILE  ;
: UWORD      WORD  DUP COUNT UPPER  ;
: TEXT      HERE C/L 1+   BLANK UWORD   PAD C/L 1+ CMOVE ;
: TAB ( n--)  #OUT @ - DUP 0> IF SPACES ELSE DROP THEN ;
: 2AND  (S d d -- d ) 2 ROLL AND ROT ROT AND SWAP ;
: 2NOT  (S d -- d )   NOT SWAP NOT SWAP ;
: "FBBS2.DAT"  ( --  addr len ) " FBBS2.DAT" ;
: OPEN-DATA  ( -- )  ['] "FBBS2.DAT" IS SOURCE  >IN OFF
  OPEN ['] (SOURCE) IS SOURCE ;
: INIT-BBS  OPEN-DATA   START ;



\ COMPRESSION/FORMATING )                             03dec84tjb

: TY.R  OVER - SPACES TYPE ;
: DATE>  ( mm/dd/yy -- u )  100 UM/MOD 0 100 UM/MOD
   32 * + SWAP 416 * + ; ( this is sortable)
: >MDY  ( U -- yy dd mm) 0 416 UM/MOD SWAP 32 /MOD ;
: >DATE ( u -- mm/dd/yy)  >MDY  100 * +  100 UM* ROT 0 D+ ;
: .DATE  ( u -- )  SPACE  >DATE
   <# # # 47 HOLD # # 47 HOLD # # #> TYPE SPACE ;

      \s
\ : TRUE 1 ;    : FALSE 0 ;




\ high-speed vm i/o    * NOT IN USE *      03dec84tjb 15MAY85JAP
\ CODE 1KU/MOD   ( d -- n n )
\  D POP  H POP  B PUSH    ( save bc we need the room )
\  H A MOV  3 ANI  A B MOV  L C MOV  B PUSH ( REMAINDER)
\  H L MOV  E H MOV  D E MOV  0 D MVI  ( /256 )
\  STC CMC  ( reset cy flag )
\  E A MOV  RAR  A E MOV  H A MOV  RAR  A H MOV
\  L A MOV  RAR  A L MOV               ( D/2 )
\  STC CMC  ( reset cy flag )
\  E A MOV  RAR  A E MOV  H A MOV  RAR  A H MOV
\  L A MOV  RAR  A L MOV               ( D/2 )
\  D POP  B POP  D PUSH  ( fix up stack push remainder )
\  HPUSH JMP  C;      ( push divident )
\ or in high level
: 1KU/MOD  ( d -- n n )  OVER 1023 AND ROT ROT
     10 0 DO D2/ LOOP  DROP ; \ dividend on top
\ Some Vars and virtual stuff  * NOT IN USE *         15MAY85JAP
 2VARIABLE VDP       2VARIABLE V.PTR
 0. VDP 2!           0. V.PTR 2!
0 CONSTANT VBLK  VARIABLE RES   128. 2CONSTANT VOFF
: V+ V.PTR DUP 2@ 1. D+ ROT 2! ;
: V- V.PTR DUP 2@ -1. D+ ROT 2! ;
: VADDR ( d--n) VOFF D+  1KU/MOD VBLK + BLOCK
  OVER 1024 SWAP - RES !  + ;
: V@ ( d--c)  VADDR C@ ;
: V! ( c d --) VADDR C! UPDATE ;
: >V ( c --) V.PTR 2@ V! V+ ;
: V> ( -- c) V.PTR 2@ V@ V+ ;
: V  V.PTR 2@ ;



\ multi-char VM I/0                       03dec84tjb
  2VARIABLE CUR-MSG
  2VARIABLE NEW.PTR   2VARIABLE SCAN-ROOT
 0. CUR-MSG 2!
 VARIABLE TODAY
  CREATE  DATE       2 ,   0 ,
  CREATE  LENGTH     4 ,   2 ,
  CREATE  PARENT     4 ,   6 ,
  CREATE  YOUNGER    4 ,  10 ,
  CREATE  OLDER      4 ,  14 ,
  CREATE  DAUGHTER   4 ,  18 ,
  CREATE  USAGE      2 ,  22 ,
  CREATE  FILE-TYPE  1 ,  24 ,

: >NAME  25. D+ ;

\  more vm i/o                                        03dec84tjb

 CREATE HEADER 25 ALLOT  2VARIABLE HADDR

: HEADER@ 2DUP HADDR 2!  VADDR RES @ 25 > IF
  HEADER 25 CMOVE HADDR 2@ >NAME V.PTR 2! ELSE HADDR 2@
  V.PTR 2! HEADER 25 + HEADER DO V> I C! LOOP THEN ;

: HEADER! V.PTR 2!  HEADER 25 + HEADER DO I C@ >V LOOP ;
: HADDR!  HADDR 2@ HEADER! ;
: >HEADER DUP 2+ @ HEADER +  SWAP @ DUP 4 = IF DROP 2! ELSE
  2 = IF ! ELSE C! THEN THEN ;
: HEADER>  DUP 2+ @ HEADER + SWAP @ DUP 4 = IF DROP 2@ ELSE
  2 = IF  @  ELSE  C@ THEN THEN ;
: CLR-HEADER HEADER 25 + HEADER DO 0 I C! LOOP ;

\ Routine to show whats in the header                 03dec84tjb

: HEADER?  CR
  ."  haddr: "  HADDR 2@ D. CR
  ."   date: " DATE HEADER> .DATE CR
  ." length: " LENGTH HEADER> D. CR
  ." parent: " PARENT HEADER> D. CR
  ." younger: " YOUNGER HEADER> D. CR
  ."  older:  " OLDER HEADER> D. CR
  ." daughter: "  DAUGHTER HEADER> D. CR
  ." usage: " USAGE HEADER> U. CR
  ." file type: " FILE-TYPE HEADER> U. CR
  ." cur-msg: "  CUR-MSG 2@ D. CR
  ." vdp:   " VDP 2@ D. CR CR ;
: CUR-HEAD?  CUR-MSG 2@ HEADER@ HEADER? ;

\ START STOP SET-DATE                                 03dec84tjb

: START OPENFILE VBLK BLOCK 2@ VDP 2!   0. CUR-MSG 2!
  VBLK BLOCK 4 + @ TODAY ! ;


: STOP  VDP 2@ VBLK BLOCK 2!
  TODAY @ VBLK BLOCK 4 + ! UPDATE FLUSH ;

: SET-DATE   BEGIN CR ." system date is " TODAY @ .DATE CR
  ." Hit <cr> if correct, else enter new mmddyy: "
  QUERY  BL WORD NUMBER? DROP DATE> DUP 0= IF NOT ELSE TODAY !
  0 THEN UNTIL CR ;



\ routines used to set up the header                  03dec84tjb

: >DTR CUR-MSG 2@ HEADER@ DAUGHTER HEADER> CUR-MSG 2! ;

: YOUNGEST  \ find youngest sister of cur-msg
  BEGIN  CUR-MSG 2@ HEADER@ YOUNGER HEADER> 2DUP D0= NOT
  WHILE CUR-MSG 2! REPEAT 2DROP ;


: INIT-BBS  0. VDP 2!  0. CUR-MSG 2! ;






\ header-related things                               03dec84tjb


: SET-LINKS   NEW.PTR 2@ HEADER@ CUR-MSG 2@  PARENT >HEADER
  NEW.PTR 2@ HEADER!  CUR-MSG 2@ HEADER@ DAUGHTER HEADER>
  D0= IF  NEW.PTR 2@ DAUGHTER >HEADER CUR-MSG 2@ HEADER!
  NEW.PTR 2@ HEADER@ CUR-MSG 2@ OLDER >HEADER ELSE >DTR
  YOUNGEST NEW.PTR 2@ YOUNGER >HEADER HADDR!
  NEW.PTR 2@ HEADER@ CUR-MSG 2@ OLDER >HEADER THEN
  0. YOUNGER >HEADER  NEW.PTR 2@ HEADER!  ;

: DO-HEADER ( d --) \ set up header for new message
  CLR-HEADER  TODAY @ DATE >HEADER
  VDP 2@ NEW.PTR 2@ D- LENGTH >HEADER
  1 FILE-TYPE >HEADER NEW.PTR 2@ HEADER! SET-LINKS ;

\ The LIST function (reads current message)           03dec84tjb

: K?    KEY? IF KEY 31 AND DUP 11 = ABORT" killed. "  19 =
          IF KEY DROP THEN THEN ; ( K to kill or S to pause )
 \ K? is case and control independent  any S or K will do
: TYPER  BEGIN K? V> DUP 127 AND DUP EMIT
  13 = IF 10 EMIT THEN 127 > UNTIL ;

: TYPE-LINE BEGIN V> DUP 127 AND DUP 13 = IF DROP 128 OR
  ELSE EMIT THEN 127 > UNTIL CR ;
: INCU  USAGE HEADER> 1+ USAGE >HEADER HADDR 2@ HEADER! ;
: .HEAD  CUR-MSG 2@ HEADER@ INCU CR ." PARENT: " PARENT HEADER>
  >NAME V.PTR 2! TYPER 40 TAB DATE HEADER> ." DATE: " .DATE
  CR CUR-MSG 2@  >NAME V.PTR 2! ." MESSAGE: " TYPER
  40 TAB USAGE HEADER>  ." USAGE: " U. CR CR ;

\ a simple editor                                     03dec84tjb
  2VARIABLE  E.PTR
: VMARK  V- V> 128 OR V- >V ;

: LINE>V QUERY 1 WORD COUNT DUP >R
   0 ?DO DUP C@ >V 1+ LOOP
  DROP CR  13 >V R> ;

: MNH   ( Message Name Header )
       VDP 2@  2DUP NEW.PTR 2! >NAME 2DUP VADDR DROP V.PTR 2!
  SET-DATE  ." MESSAGE NAME? " QUERY 32 UWORD COUNT 32 MIN
  DUP 0= ABORT" bad name"
  0 DO DUP C@  >V 1+ LOOP DROP VMARK CR ;



\ MESSEGE ENTRY RELATED STUFF                         03dec84tjb


: ED  MNH   ." Press  CR twice to exit editor" CR CR
  BEGIN  LINE>V  0= UNTIL V- VMARK V.PTR 2@ 2DUP E.PTR 2!
  VDP 2@ D- ." MESSAGE LENGTH: "  D. ."  BYTES." CR
  ." OPTIONS:    LL  SAVEIT" CR ;


: LL  NEW.PTR 2@  >NAME V.PTR 2! CR ." name:  " TYPER CR CR
  TYPER CR ;
: LIST  LL ;
: SAVEIT  E.PTR 2@ VDP 2!  DO-HEADER CR ;
: SAVEPERMANENT  SAVEIT ;
: S   SAVEIT ;

\ submessage function                                 03dec84tjb

   VARIABLE  SINCE

: SUB-MSG CR CR  CUR-MSG 2@ HEADER@ DAUGHTER HEADER> 2DUP  D0=
  IF 2DROP ." no submessages"  ELSE ." SUBMESSAGES: " CR
  BEGIN HEADER@ DATE HEADER>  SINCE @ U< NOT IF
  HADDR 2@ >NAME V.PTR 2! TYPER
  35 TAB DATE HEADER> .DATE CR THEN
  YOUNGER HEADER> 2DUP D0= UNTIL 2DROP THEN CR ;






\ scanning the tree                                   03dec84tjb
   VARIABLE  LEVEL

: NEXT-MSG ( --f)   CUR-MSG 2@ HEADER@ DAUGHTER HEADER>
  2DUP D0= NOT IF CUR-MSG 2!  1 LEVEL +!  1 ELSE  2DROP
  YOUNGER HEADER> 2DUP D0= NOT IF CUR-MSG 2! 1 ELSE 2DROP BEGIN
  PARENT HEADER> 2DUP CUR-MSG 2! -1 LEVEL +! 2DUP SCAN-ROOT
  2@ D= IF 2DROP 0 1 ELSE HEADER@ YOUNGER HEADER> 2DUP D0= NOT
  IF CUR-MSG 2! 1 1 ELSE 2DROP 0 THEN THEN K? UNTIL THEN THEN ;
    \ K? allows user to escape long searches
: NN 0. SCAN-ROOT 2! NEXT-MSG IF .HEAD TYPER SUB-MSG ELSE
  CR ." nothing more to read" CR THEN ;

: BB CUR-MSG 2@ HEADER@ OLDER HEADER> CUR-MSG 2!
  .HEAD TYPER SUB-MSG ;

\ stuff for findin things by name                     03dec84tjb
  CREATE NAME-BUF  40 ALLOT  VARIABLE NAME-LEN

: ?NAME   BL TEXT  PAD 1+ NAME-BUF 40 CMOVE
   NAME-BUF  40 -TRAILING DUP 0= ABORT" bad name"
   DUP NAME-LEN ! 1-  + DUP C@ 128 OR SWAP C!
   BL WORD NUMBER? DROP DATE> SINCE ! ;

: -NAME >NAME V.PTR 2! 1 NAME-BUF DUP NAME-LEN @ +
  SWAP DO I C@ V> = AND DUP 0= IF LEAVE THEN LOOP ;

: FIND-NAME  0. 2DUP CUR-MSG 2! SCAN-ROOT 2!
  BEGIN CUR-MSG 2@ -NAME IF 0 EXIT THEN NEXT-MSG 0= UNTIL 1 ;



\ some real stuff                                     03dec84tjb
: FINDER ?NAME FIND-NAME  IF ." <-- message not in tree."
  ABORT THEN CR ; : GOTO  FINDER ;
: READ  FINDER .HEAD  TYPER   SUB-MSG ;
: R  READ ;
: BROWSE FINDER .HEAD  TYPE-LINE CR  SUB-MSG ;

: ADDTO  FINDER ED ;

: INDEX  FINDER  CUR-MSG 2@ 2DUP SCAN-ROOT 2! HEADER@  0 LEVEL !
  DAUGHTER HEADER> D0= ABORT" nothing to index"
  BEGIN NEXT-MSG WHILE CUR-MSG 2@ HEADER@ DATE HEADER> SINCE @
  U< NOT IF LEVEL @ 2* SPACES CUR-MSG 2@ HEADER@
  TYPER 40 TAB DATE HEADER> .DATE 55 TAB USAGE HEADER> .
  LENGTH HEADER> 65 TAB D. CR  THEN  REPEAT CR ;

\ start of file maintainence                          03dec84tjb

: DE-LINK   CUR-MSG 2@ HEADER@ PARENT HEADER> OLDER HEADER>
  D= IF YOUNGER HEADER> 2DUP PARENT HEADER> HEADER@ DAUGHTER
  >HEADER  HADDR! 2DUP D0= IF 2DROP ELSE HEADER@ PARENT HEADER>
  OLDER >HEADER HADDR! THEN
 ELSE YOUNGER HEADER> 2DUP OLDER HEADER>  HEADER@ YOUNGER
  >HEADER HADDR!  D0= NOT IF  HADDR 2@ YOUNGER HEADER>
  HEADER@  OLDER >HEADER HADDR! THEN  THEN ;







\ more file maintanence                               03dec84tjb

: REMOVE  FINDER CUR-MSG 2@ NEW.PTR 2! DE-LINK CR ;

: MOVETO FINDER SET-LINKS CR ;











\  Z80 SIO WORDS                          21oct84jap  18may85jap
\ MODIFIED FOR MORROW DECISION'S 8251
  HEX

\ CREATE SIO$  1818 , 1 , 4C04 , 5103 , EA05 ,
  FC CONSTANT ADAT   FD CONSTANT BDAT
  FF CONSTANT ACON   FF CONSTANT BCON

: SINIT         ;
 \       SIO$ DUP 0A + SWAP DO I C@ BCON PC! LOOP ;
: MSTAT    0FF PC@  ;
: DCD?    MSTAT  80 AND ; \ 10 BCON PC!  BCON PC@ 8 AND 8 = ;

\ BAUD 12C = IF 5 ELSE 7 THEN 0C PC! ;

 DECIMAL
\ more modem/serial support                           21oct84jap
: GEMIT  DUP (EMIT) <MEMIT> ;
: SHARE   CHAT ; \ ' GKEY CFA 'KEY !  ' GEMIT CFA 'EMIT !
: TALK  CR ." Use control C to exit talk mode" CR
  BEGIN  MKEY DUP GEMIT 13 = IF 10 EMIT THEN AGAIN ;

: BYE  ." so long!" CR  SHARE BEGIN DCD? NOT UNTIL
  BEGIN KEY? ABORT" BROKE" DCD? UNTIL SINIT KEY KEY 2DROP
."  Welcome to Jeff's bulletin board!" CR
." type READ BBS to start,  READ HELP for help" CR CR ;

: HELP CR ." type READ HELP if you need help." CR ;




\  limiting the trouble we get into                   21oct84jap

: TPEE    \ this is the command to return to forth
   ['] (?ERROR) IS ?ERROR STOP CR TRUE ABORT" back to forth" ;

CREATE CMDS  ' READ ,  ' BROWSE , ' INDEX , ' NN ,  ' HELP ,
  ' TALK , ' BYE ,
  ' TPEE ,  ' ADDTO , ' SAVEIT , ' LL , ' REMOVE ,
  ' MOVETO ,
12 CONSTANT #CMDS

: CMD-OK? 0 #CMDS 0 DO OVER I 2* CMDS + @  = OR LOOP ;




\  limiting the trouble we get into                   15MAY85JAP
: GET-CMD
   DEFINED  NOT  ABORT" What??? " ;

: RUNBBS  BEGIN   CR ." COMMAND? " QUERY   GET-CMD
  CMD-OK? NOT
    IF ."  BBS CMDS ONLY " HELP DROP ELSE EXECUTE THEN AGAIN ;

: (?BBSERROR)   (S adr len f -- )
   IF  >R >R   SP0 @ SP!
       R> R> SPACE TYPE SPACE RUNBBS
   ELSE  2DROP  THEN  ;

: SAFER  ['] (?BBSERROR) IS ?ERROR  START  ONLY FBBS ALSO
   TRUE  ABORT" enter TPEE to return to forth " ;
\S **** End of the first part of the BBS, less File maintenance.
\  words used by PACK                                 03dec84tjb
  2VARIABLE  T.BASE  2VARIABLE T.PTR  VARIABLE #MSGS

: T.PTR+  T.PTR 2@ 4. D+  T.PTR 2! ;
: >TABLE  T.PTR 2@ VADDR 2! UPDATE T.PTR+ ;
: TABLE>  T.PTR 2@ VADDR 2@ T.PTR+ ;

: MAKE-TABLE  VDP 2@  8. D+ 7. 2NOT   2AND  2DUP
  T.BASE  2!  T.PTR  2!  0. CUR-MSG 2!  0 #MSGS !
  BEGIN  CUR-MSG 2@ 2DUP >TABLE >TABLE 1 #MSGS +!
  NEXT-MSG 0= UNTIL -1. >TABLE  -1. >TABLE
  CR  #MSGS @ . ." messages in tree" CR ;

: IN-TBL?  T.BASE 2@ T.PTR 2!  BEGIN 2DUP  TABLE> D= NOT
  WHILE TABLE> 0. D< IF  0 EXIT THEN REPEAT  1 ;
\ syntax = ( d -- d f)
\ more words for pack                                 03dec84tjb

: FIND-LINK  IN-TBL? 0= IF ." WARNING! bad link: " D. CR
  0. 2SWAP  THEN  2DROP ;
: SET-NEW  ( old, new--) 2SWAP  FIND-LINK  >TABLE ;

: NEW-LINK ( old -- new)   FIND-LINK  TABLE> ;


: NEW-LINKS  ( d --)   HEADER@
  PARENT  HEADER> NEW-LINK PARENT >HEADER
  DAUGHTER HEADER> NEW-LINK DAUGHTER >HEADER
  YOUNGER  HEADER> NEW-LINK YOUNGER >HEADER
  OLDER  HEADER> NEW-LINK  OLDER >HEADER  HADDR! ;


\ more words for pack                                 03dec84tjb
   2VARIABLE SRC.PTR  2VARIABLE DES.PTR

 : >DES  DES.PTR 2@ V!  DES.PTR DUP 2@ 1. D+ ROT 2! ;
: SRC+  SRC.PTR DUP 2@ LENGTH HEADER> D+ ROT 2! ;
: >>DES  ( d.src d.cnt )
  BEGIN  2DUP 0. D> WHILE  2SWAP 2DUP
  V@ >DES  1. D+ 2SWAP 1. D- REPEAT 2DROP 2DROP  ;

: SQUISH  0. HEADER@ LENGTH HEADER> 2DUP SRC.PTR 2!
  DES.PTR 2!  #MSGS @ 1 DO  42 EMIT
  SRC.PTR 2@  BEGIN  2DUP HEADER@ IN-TBL? 0= WHILE 45 EMIT
  LENGTH HEADER> 2+ REPEAT  SRC.PTR 2! DES.PTR 2@ >TABLE
  CR SRC.PTR 2@ D.   DES.PTR 2@ D.
  SRC.PTR 2@ LENGTH HEADER> >>DES  SRC+ LOOP DES.PTR 2@ VDP 2! ;

\  PACK                                               03dec84tjb

: RE-LINK   #MSGS @ 0 DO  I 8 UM* T.BASE 2@ D+ 4. D+ VADDR 2@
  NEW-LINKS  LOOP ;

: PACK  CR ." are you sure? " KEY 89 = NOT ABORT" pack aborted."
  CR ." making link table"  MAKE-TABLE
  CR ." squishing the tree" CR SQUISH
  CR ." reseting links"  RE-LINK
  CR ." all done!" CR ;

: .TABLE  CR #MSGS @ 0 DO I 8 UM* T.BASE 2@ D+ VADDR
  DUP  2@ D. 4 +  2@ D. CR LOOP CR ;



\  file i/o to cp/m

 CREATE SECBUF 128 ALLOT  VARIABLE DCNT

: ?FILE   ?NAME  PAD 33 0 FILL PAD 1+ 11 BLANK
  NAME-LEN @ 0 DO I NAME-BUF + C@ 127 AND I PAD + 1+ C! LOOP ;

: READ-FILE  ?FILE  15 PAD SYSCALL 4 > ABORT" file not found" ;

: READIT CR  BEGIN 26 SECBUF SYSCALL DROP  20 PAD SYSCALL 0=
  WHILE  SECBUF 128 + SECBUF DO  I C@ DUP 26 =
  IF DROP CR ." EOF" LEAVE ELSE EMIT THEN LOOP  REPEAT ;

: READF  READ-FILE READIT ;


\  file i/o to cp/m                                   03dec84tjb


: IMPORT  READ-FILE   MNH
  BEGIN 26 SECBUF SYSCALL DROP
  20 PAD SYSCALL 0= WHILE 128 0 DO SECBUF I +  C@
  127 AND DUP 10 = IF DROP ELSE DUP 26 = IF DROP LEAVE ELSE
  >V THEN THEN LOOP  REPEAT VMARK V.PTR 2@ E.PTR 2! CR ;








\  file i/o to cp/m                                   03dec84tjb

: WR-SEC  26 SECBUF SYSCALL DROP  21 PAD SYSCALL 0=
  NOT  ABORT" ERROR: disk full" ;

: >DISK  DCNT @ DUP 128 U< IF SECBUF + C! 1 DCNT +! ELSE
  DROP  0 DCNT ! WR-SEC SECBUF 128 26 FILL THEN ;

: EXPORT   13 0 SYSCALL DROP  14 0 SYSCALL DROP ?FILE
  22 PAD SYSCALL  4 >  ABORT" disk directory full"
  CUR-MSG 2@ >NAME V.PTR 2! ." exporting " TYPER CR
  0 DCNT !  BEGIN V> DUP 127 AND DUP 13 = IF 10 >DISK THEN
  >DISK 127 > UNTIL WR-SEC  16 PAD SYSCALL DROP ;



\  back pointer fixer upper                           03dec84tjb


: FIX-DTRS  CUR-MSG 2@ 2DUP HEADER@ DAUGHTER HEADER> BEGIN
  2DUP D0= NOT WHILE   HEADER@ OLDER >HEADER HADDR! HADDR 2@
  YOUNGER HEADER> REPEAT  2DROP 2DROP ;

: FIX-BACK  0.  2DUP CUR-MSG 2! SCAN-ROOT 2!  BEGIN
  FIX-DTRS NEXT-MSG 0= UNTIL CR ;

: LIST-PHYS  CR 0. CUR-MSG 2!  BEGIN  CUR-MSG 2@ VDP 2@ D=
  NOT WHILE CUR-MSG 2@ 2DUP HEADER@ TYPER 35 TAB D. 50 TAB
  LENGTH HEADER> 2DUP D. CR
  CUR-MSG 2@ D+ CUR-MSG 2! REPEAT ;


\ MESSAGE MOVING WORDS

: TYPE>V   (S addr --   | puts memory into virtual )
   BEGIN DUP  C@ DUP EMIT DUP >V DUP > 128 SWAP 0= OR
     SWAP 1+ SWAP
   UNTIL DROP ;

: MED  MNH   ." Enter address of existing message " CR CR
  QUERY INTERPRET TYPE>V V- VMARK V.PTR D@ DDUP E.PTR D!
  VDP D@ D- ." MESSAGE LENGTH: "  D. ."  BYTES." CR
  ." OPTIONS:    LL  SAVEIT" CR ;





\ BBS TOOLS                                           17oct84jap

: CUR?   CUR-HEAD? ;
: NPAR    PARENT >HEADER ;
: NYOUNG  YOUNGER >HEADER ;
: NKID    DAUGHTER >HEADER ;
: UNUSED  0 USAGE >HEADER ;
: NOLDER  OLDER >HEADER ;
: CUR!    CUR-MSG D@ HEADER! ;







\ MESSAGE MOVING WORDS

: TYPE>V   (S addr --   | puts memory into virtual )
   BEGIN DUP  C@ DUP EMIT DUP >V DUP > 128 SWAP 0= OR
     SWAP 1+ SWAP
   UNTIL DROP ;

: MED  MNH   ." Enter address of existing message " CR CR
  QUERY INTERPRET TYPE>V V- VMARK V.PTR D@ DDUP E.PTR D!
  VDP D@ D- ." MESSAGE LENGTH: "  D. ."  BYTES." CR
  ." OPTIONS:    LL  SAVEIT" CR ;





����������������������������������������������������������������
����������������������������������������������������������������
����������������������������������������������������������������
����������������������������������������������������������������
����������������������������������������������������������������
����������������������������������������������������������������
����������������������������������������������������������������
����������������������������������������������������������������








\ start of file maintainence                          03dec84tjb

: DE-LINK   CUR-MSG 2@ HEADER@ PARENT HEADER> OLDER HEADER>
  D= IF YOUNGER HEADER> 2DUP PARENT HEADER> HEADER@ DAUGHTER
  >HEADER  HADDR! 2DUP D0= IF 2DROP ELSE HEADER@ PARENT HEADER>
  OLDER >HEADER HADDR! THEN
 ELSE YOUNGER HEADER> 2DUP OLDER HEADER>  HEADER@ YOUNGER
  >HEADER HADDR!  D0= NOT IF  HADDR 2@ YOUNGER HEADER>
  HEADER@  OLDER >HEADER HADDR! THEN  THEN ;







\ more file maintanence                               03dec84tjb

: REMOVE  FINDER CUR-MSG 2@ NEW.PTR 2! DE-LINK CR ;

: MOVETO FINDER SET-LINKS CR ;











FORTH Bulitin Board System (FBBS)         15JAN85JAP  15MAY85JAP
I can't get it to compile of F83 2.1.2  (See FBBS1.COM it works)

Screen 2 is ideas, 3 is patches to F83 to match M.V.P. Forth.
4-25 is code for basic BBS  26-36 file handling stuff(untested)
Data in the tree is now in a separate file.  You can run FBBS2
.COM from your keyboard.  Screen 31 must be modified for your
system. To allow for a larger BBS, change construct VBLK to 0
and use a new file.  The BBS is in a seperate vocabulary, FBBS.
   To begin the BBS type:
         FBBS   0 IS VBLK   and  START or SAFER
SAFER allows only BBS commands, and protects the system from the
user.  Type TPEE to return to FORTH.  Type READ BBS to start.
READ HELP or READ COMMANDS are good too.


\ Load screen for FORTH BBS               26nov84tjb  15MAY85JAP
 15 VIEWS BBS2.BLK    .( LOADING )  FILE? CR
 3 4  THRU  \ 5 6 THRU  ( Virtual I/O )
 7 25 THRU     ( 0 IS VBLK )
 S-S BBS2.COM   EXIT
 26 36 THRU  EXIT  data packing  ( SYSCALL is undefined JP)
 Type OPEN BBS2.DAT  0 IS VBLK  and  START or SAFER
The orginal concept execution and code is Jeff's baby.
I started the conversion to F83, but Tom actually succeded.
You will see my initials on the ID date but let me assure you it
is Jeffs progrm.         John Peters, F83 Disk Librarian
                                      (415) 239-5393 after 7 pm.
  Jeff Wilson  WA2KCM           Tom Belpasso
  55 Bedford Ave.               852-116 Minnesota Avenue
  Bergenfield NJ 07621          San Jose, CA 95125
  (201) 384-1596  MVP version   (408) 292-0352  LP F-83 version
                                                      15MAY85JAP















Aborts current command��  y                FORT�This branch
 is dedicated to the programming language FORTH.
This BBS was wr
itten in FORTH.��  �           �     TEST-WOR�This is a test
 message to check out the system after completely
converting the
 code to FORTH-83.��  c   �       '     COMMAND�Allowable co
mmands are:
READ BROWSE INDEX ADDTO LL SAVEIT and BYE��  l   � 
      '      COMMAND�Allowable commands are:
READ BROWSE INDEX
 NN ADDTO LL SAVEIT TALK and BYE �
UUUUUUUUUUUUUUUUUUUUUUUUUUUUU
UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
