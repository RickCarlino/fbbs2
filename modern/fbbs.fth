\ ===== WORDS THAT NEED REPLACEMENT ON MODERN (NON-F83) SYSTEMS:
: DOS ." MISSING DOS" ;
: UPPER ." MISSING UPPER" ;
: #OUT ." MISSING #OUT" ;
: NOT ." MISSING NOT" ;
: OPEN ." MISSING OPEN" ;
\ ===== END STUBS =====

ONLY FORTH ALSO
VOCABULARY FBBS FBBS DEFINITIONS ALSO
: OPENFILE [ DOS ] OPEN-FILE ;
: UWORD WORD DUP COUNT UPPER ;
: TEXT HERE C/L 1+ BLANK UWORD PAD C/L 1+ CMOVE ;
: TAB ( n -- )
  #OUT @ - DUP 0> IF SPACES ELSE DROP THEN ;
: 2AND ( d d -- d ) 2 ROLL AND ROT ROT AND SWAP ;
: 2NOT ( d -- d ) NOT SWAP NOT SWAP ;
: "FBBS2.DAT" ( -- addr len ) s" FBBS2.DAT" ;
: OPEN-DATA ( -- ) ['] "FBBS2.DAT" IS SOURCE >IN OFF OPEN ['] (SOURCE) IS SOURCE ;
: INIT-BBS OPEN-DATA START ;
: TY.R OVER - SPACES TYPE ;
: DATE> ( mm/dd/yy -- u ) 100 UM/MOD 0 100 UM/MOD 32 * + SWAP 416 * + ; ( this is sortable)
: >MDY ( U -- yy dd mm) 0 416 UM/MOD SWAP 32 /MOD ;
: >DATE ( u -- mm/dd/yy) >MDY 100 * + 100 UM* ROT 0 D+ ;
: .DATE ( u -- ) SPACE >DATE <# # # 47 HOLD # # 47 HOLD # # #> TYPE SPACE ;

2VARIABLE CUR-MSG
2VARIABLE NEW.PTR 2VARIABLE SCAN-ROOT
0. CUR-MSG 2!
VARIABLE TODAY
CREATE DATE 2 , 0 ,
CREATE LENGTH 4 , 2 ,
CREATE PARENT 4 , 6 ,
CREATE YOUNGER 4 , 10 ,
CREATE OLDER 4 , 14 ,
CREATE DAUGHTER 4 , 18 ,
CREATE USAGE 2 , 22 ,
CREATE FILE-TYPE 1 , 24 ,

: >NAME 25. D+ ;

CREATE HEADER 25 ALLOT 2VARIABLE HADDR

: HEADER@
  2DUP HADDR 2! VADDR RES @ 25 >
  IF
    HEADER 25 CMOVE HADDR 2@ >NAME V.PTR 2!
  ELSE
    HADDR 2@ V.PTR 2! HEADER 25 + HEADER
    DO
      V> I C!
    LOOP
  THEN ;

: HEADER!
  V.PTR 2! HEADER 25 + HEADER
  DO
    I C@ >V
  LOOP ;
: HADDR! HADDR 2@ HEADER! ;
: >HEADER
  DUP 2+ @ HEADER + SWAP @ DUP 4 =
  IF
    DROP 2!
  ELSE
    2 =
    IF
      !
    ELSE
      C!
    THEN
  THEN ;

: HEADER>
  DUP 2+ @ HEADER + SWAP @ DUP 4 =
  IF
    DROP 2@
  ELSE
    2 =
    IF
      @
    ELSE
      C@
    THEN
  THEN ;

: CLR-HEADER
  HEADER 25 + HEADER
  DO
    0 I C!
  LOOP ;

: HEADER? CR
." haddr: " HADDR 2@ D. CR
." date: " DATE HEADER> .DATE CR
." length: " LENGTH HEADER> D. CR
." parent: " PARENT HEADER> D. CR
." younger: " YOUNGER HEADER> D. CR
." older: " OLDER HEADER> D. CR
." daughter: " DAUGHTER HEADER> D. CR
." usage: " USAGE HEADER> U. CR
." file type: " FILE-TYPE HEADER> U. CR
." cur-msg: " CUR-MSG 2@ D. CR
." vdp: " VDP 2@ D. CR CR ;
: CUR-HEAD? CUR-MSG 2@ HEADER@ HEADER? ;

: START OPENFILE VBLK BLOCK 2@ VDP 2! 0. CUR-MSG 2!
VBLK BLOCK 4 + @ TODAY ! ;

: STOP VDP 2@ VBLK BLOCK 2!
TODAY @ VBLK BLOCK 4 + ! UPDATE FLUSH ;

: SET-DATE
  BEGIN
    CR ." system date is "
    TODAY @ .DATE CR
    ." Hit <cr> if correct, else enter new mmddyy: "
    QUERY BL WORD NUMBER? DROP DATE> DUP 0=
    IF
      NOT
    ELSE
      TODAY ! 0
    THEN
  UNTIL
  CR ;

: >DTR CUR-MSG 2@ HEADER@ DAUGHTER HEADER> CUR-MSG 2! ;

: YOUNGEST \ find youngest sister of cur-msg
  BEGIN
    CUR-MSG 2@ HEADER@ YOUNGER HEADER> 2DUP D0= NOT
  WHILE
    CUR-MSG 2!
  REPEAT
  2DROP ;

: INIT-BBS 0. VDP 2! 0. CUR-MSG 2! ;

: SET-LINKS
  NEW.PTR 2@ HEADER@ CUR-MSG 2@ PARENT >HEADER NEW.PTR 2@ HEADER!
  CUR-MSG 2@ HEADER@ DAUGHTER HEADER> D0=
  IF
    NEW.PTR 2@ DAUGHTER >HEADER CUR-MSG 2@ HEADER! NEW.PTR 2@
    HEADER@ CUR-MSG 2@ OLDER >HEADER
  ELSE
    >DTR YOUNGEST NEW.PTR 2@ YOUNGER >HEADER HADDR! NEW.PTR
    2@ HEADER@ CUR-MSG 2@ OLDER >HEADER
  THEN
  0. YOUNGER >HEADER NEW.PTR 2@ HEADER! ;

: DO-HEADER ( d --) \ set up header for new message
CLR-HEADER TODAY @ DATE >HEADER
VDP 2@ NEW.PTR 2@ D- LENGTH >HEADER
1 FILE-TYPE >HEADER NEW.PTR 2@ HEADER! SET-LINKS ;

: K? KEY? IF KEY 31 AND DUP 11 = ABORT" killed. " 19 =
IF KEY DROP THEN THEN ; ( K to kill or S to pause )
\ K? is case and control independent any S or K will do
: TYPER BEGIN K? V> DUP 127 AND DUP EMIT
13 = IF 10 EMIT THEN 127 > UNTIL ;

: TYPE-LINE BEGIN V> DUP 127 AND DUP 13 = IF DROP 128 OR
ELSE EMIT THEN 127 > UNTIL CR ;
: INCU USAGE HEADER> 1+ USAGE >HEADER HADDR 2@ HEADER! ;
: .HEAD CUR-MSG 2@ HEADER@ INCU CR ." PARENT: " PARENT HEADER>
>NAME V.PTR 2! TYPER 40 TAB DATE HEADER> ." DATE: " .DATE
CR CUR-MSG 2@ >NAME V.PTR 2! ." MESSAGE: " TYPER
40 TAB USAGE HEADER> ." USAGE: " U. CR CR ;
2VARIABLE E.PTR
: VMARK V- V> 128 OR V- >V ;

: LINE>V QUERY 1 WORD COUNT DUP >R
0 ?DO DUP C@ >V 1+ LOOP
DROP CR 13 >V R> ;

: MNH ( Message Name Header )
VDP 2@ 2DUP NEW.PTR 2! >NAME 2DUP VADDR DROP V.PTR 2!
SET-DATE ." MESSAGE NAME? " QUERY 32 UWORD COUNT 32 MIN
DUP 0= ABORT" bad name"
0 DO DUP C@ >V 1+ LOOP DROP VMARK CR ;

: ED MNH ." Press CR twice to exit editor" CR CR
BEGIN LINE>V 0= UNTIL V- VMARK V.PTR 2@ 2DUP E.PTR 2!
VDP 2@ D- ." MESSAGE LENGTH: " D. ." BYTES." CR
." OPTIONS: LL SAVEIT" CR ;

: LL NEW.PTR 2@ >NAME V.PTR 2! CR ." name: " TYPER CR CR
TYPER CR ;
: LIST LL ;
: SAVEIT E.PTR 2@ VDP 2! DO-HEADER CR ;
: SAVEPERMANENT SAVEIT ;
: S SAVEIT ;

VARIABLE SINCE

: SUB-MSG CR CR CUR-MSG 2@ HEADER@ DAUGHTER HEADER> 2DUP D0=
IF 2DROP ." no submessages" ELSE ." SUBMESSAGES: " CR
BEGIN HEADER@ DATE HEADER> SINCE @ U< NOT IF
HADDR 2@ >NAME V.PTR 2! TYPER
35 TAB DATE HEADER> .DATE CR THEN
YOUNGER HEADER> 2DUP D0= UNTIL 2DROP THEN CR ;

VARIABLE LEVEL

: NEXT-MSG ( --f) CUR-MSG 2@ HEADER@ DAUGHTER HEADER>
2DUP D0= NOT IF CUR-MSG 2! 1 LEVEL +! 1 ELSE 2DROP
YOUNGER HEADER> 2DUP D0= NOT IF CUR-MSG 2! 1 ELSE 2DROP BEGIN
PARENT HEADER> 2DUP CUR-MSG 2! -1 LEVEL +! 2DUP SCAN-ROOT
2@ D= IF 2DROP 0 1 ELSE HEADER@ YOUNGER HEADER> 2DUP D0= NOT
IF CUR-MSG 2! 1 1 ELSE 2DROP 0 THEN THEN K? UNTIL THEN THEN ;
\ K? allows user to escape long searches
: NN 0. SCAN-ROOT 2! NEXT-MSG IF .HEAD TYPER SUB-MSG ELSE
CR ." nothing more to read" CR THEN ;

: BB CUR-MSG 2@ HEADER@ OLDER HEADER> CUR-MSG 2!
.HEAD TYPER SUB-MSG ;
CREATE NAME-BUF 40 ALLOT VARIABLE NAME-LEN

: ?NAME BL TEXT PAD 1+ NAME-BUF 40 CMOVE
NAME-BUF 40 -TRAILING DUP 0= ABORT" bad name"
DUP NAME-LEN ! 1- + DUP C@ 128 OR SWAP C!
BL WORD NUMBER? DROP DATE> SINCE ! ;

: -NAME >NAME V.PTR 2! 1 NAME-BUF DUP NAME-LEN @ +
SWAP DO I C@ V> = AND DUP 0= IF LEAVE THEN LOOP ;

: FIND-NAME 0. 2DUP CUR-MSG 2! SCAN-ROOT 2!
BEGIN CUR-MSG 2@ -NAME IF 0 EXIT THEN NEXT-MSG 0= UNTIL 1 ;

: FINDER ?NAME FIND-NAME IF ." <-- message not in tree."
ABORT THEN CR ; : GOTO FINDER ;
: READ FINDER .HEAD TYPER SUB-MSG ;
: R READ ;
: BROWSE FINDER .HEAD TYPE-LINE CR SUB-MSG ;

: ADDTO FINDER ED ;

: INDEX FINDER CUR-MSG 2@ 2DUP SCAN-ROOT 2! HEADER@ 0 LEVEL !
DAUGHTER HEADER> D0= ABORT" nothing to index"
BEGIN NEXT-MSG WHILE CUR-MSG 2@ HEADER@ DATE HEADER> SINCE @
U< NOT IF LEVEL @ 2* SPACES CUR-MSG 2@ HEADER@
TYPER 40 TAB DATE HEADER> .DATE 55 TAB USAGE HEADER> .
LENGTH HEADER> 65 TAB D. CR THEN REPEAT CR ;

: DE-LINK CUR-MSG 2@ HEADER@ PARENT HEADER> OLDER HEADER>
D= IF YOUNGER HEADER> 2DUP PARENT HEADER> HEADER@ DAUGHTER
>HEADER HADDR! 2DUP D0= IF 2DROP ELSE HEADER@ PARENT HEADER>
OLDER >HEADER HADDR! THEN
ELSE YOUNGER HEADER> 2DUP OLDER HEADER> HEADER@ YOUNGER
>HEADER HADDR! D0= NOT IF HADDR 2@ YOUNGER HEADER>
HEADER@ OLDER >HEADER HADDR! THEN THEN ;

: REMOVE FINDER CUR-MSG 2@ NEW.PTR 2! DE-LINK CR ;

: MOVETO FINDER SET-LINKS CR ;

\ Z80 SIO WORDS    21oct84jap 18may85jap
\ MODIFIED FOR MORROW DECISION'S 8251
HEX

\ CREATE SIO$ 1818 , 1 , 4C04 , 5103 , EA05 ,
FC CONSTANT ADAT FD CONSTANT BDAT
FF CONSTANT ACON FF CONSTANT BCON

: SINIT  ;
\ SIO$ DUP 0A + SWAP DO I C@ BCON PC! LOOP ;
: MSTAT 0FF PC@ ;
: DCD? MSTAT 80 AND ; \ 10 BCON PC! BCON PC@ 8 AND 8 = ;

\ BAUD 12C = IF 5 ELSE 7 THEN 0C PC! ;

DECIMAL       \ more modem/serial support    21oct84jap
: GEMIT DUP (EMIT) <MEMIT> ;
: SHARE CHAT ; \ ' GKEY CFA 'KEY ! ' GEMIT CFA 'EMIT !
: TALK CR ." Use control C to exit talk mode" CR
BEGIN MKEY DUP GEMIT 13 = IF 10 EMIT THEN AGAIN ;

: BYE ." so long!" CR SHARE BEGIN DCD? NOT UNTIL
BEGIN KEY? ABORT" BROKE" DCD? UNTIL SINIT KEY KEY 2DROP
." Welcome to Jeff's bulletin board!" CR
." type READ BBS to start, READ HELP for help" CR CR ;

: HELP CR ." type READ HELP if you need help." CR ;

\ limiting the trouble we get into   21oct84jap

: TPEE \ this is the command to return to forth
['] (?ERROR) IS ?ERROR STOP CR TRUE ABORT" back to forth" ;

CREATE CMDS ' READ , ' BROWSE , ' INDEX , ' NN , ' HELP ,
' TALK , ' BYE ,
' TPEE , ' ADDTO , ' SAVEIT , ' LL , ' REMOVE ,
' MOVETO ,
12 CONSTANT #CMDS

: CMD-OK? 0 #CMDS 0 DO OVER I 2* CMDS + @ = OR LOOP ;

\ limiting the trouble we get into   15MAY85JAP
: GET-CMD
DEFINED NOT ABORT" What??? " ;

: RUNBBS BEGIN CR ." COMMAND? " QUERY GET-CMD
CMD-OK? NOT
IF ." BBS CMDS ONLY " HELP DROP ELSE EXECUTE THEN AGAIN ;

: (?BBSERROR) ( adr len f -- )
IF >R >R SP0 @ SP!
R> R> SPACE TYPE SPACE RUNBBS
ELSE 2DROP THEN ;

: SAFER ['] (?BBSERROR) IS ?ERROR START ONLY FBBS ALSO
TRUE ABORT" enter TPEE to return to forth " ;
\S **** End of the first part of the BBS, less File maintenance.
