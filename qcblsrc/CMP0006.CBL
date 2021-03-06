       IDENTIFICATION DIVISION.
     �*
         PROGRAM-ID.              CMP0006.
           COPY COPYRIGHT  OF APG-QCPYSRC.
     �*
     �*---------------------------------------------------------------*
     �* F�LLEN PTMPFFD                                                *
     �*---------------------------------------------------------------*
     �*                                                               *
     �* AUTOR         :  A. PIEGER                                    *
     �*                                                               *
     �* ERSTELLT AM   :  30.10.2009                                   *
     �*                                                               *
     �* FUNKTION      :  ERSTELLEN PTMPFFD                            *
     �*                                                               *
     �* �NDERUNGEN:                                                   *
     �* DATUM      VON   GRUND DER �NDERUNG                           *
     �*                                                               *
     �*****************************************************************
     �*
       ENVIRONMENT DIVISION.
        CONFIGURATION SECTION.
         SOURCE-COMPUTER.         IBM-AS400.
         OBJECT-COMPUTER.         IBM-AS400.
        SPECIAL-NAMES. , DECIMAL-POINT IS COMMA.
      /
       INPUT-OUTPUT SECTION.
         FILE-CONTROL.

      /
       DATA DIVISION.
       FILE SECTION.
      /
       WORKING-STORAGE SECTION.

     �* STANDARDFELDER
           COPY WRKSTD      OF APG-QCPYSRC.

     �* WORKBEREICH �BERGABEPARAMETER
           COPY WRKPGMPARM  OF APG-QCPYSRC.

       01  PGM-WRK                       PIC X(10) VALUE "CMP0006".
       01  PGM-TYP                       PIC X(8)  VALUE "COMPILER".

     �* PARAMETER F�R CL-PROGRAMME
       01  DSPFFD-REC                    TYPE DSPFFD-TYPE.
      /
     �*-------------------------------------------------------------
       LINKAGE SECTION.
       01  X-LIB                         PIC X(10).
       01  X-FILE                        PIC X(10).
     �*-------------------------------------------------------------

     �*-------------------------------------------------------------
       PROCEDURE DIVISION USING X-LIB
                                X-FILE.
     �*-------------------------------------------------------------
       STEUER SECTION.
       ANFANG.

     �* F�LLEN PGM-WRK UND AUSF�HREN STANDARDROUTINEN
           MOVE     "CMP0006" TO PGM-WRK.
           PERFORM  COPY-PGM-INIT.

           PERFORM  CREATE-DSPFFD.
           IF       RET-CODE NOT = SPACES
                    GO TO ENDE
           END-IF.

       ENDE.

           PERFORM  COPY-PGM-EXIT.

           GOBACK.
      /
     �*--------------------------------------------------------------
     �* AUSF�HREN DES DSPFFD IN DIE QTEMP
     �*--------------------------------------------------------------
       CREATE-DSPFFD SECTION.
       CRT-FFD-00.

           INITIALIZE RET-CODE.
     �* DSPFFD AUSF�HREN
           INITIALIZE DSPFFD-REC.
           MOVE     X-FILE          TO FILENAME OF DSPFFD-REC.
           MOVE     X-LIB           TO LIBNAME  OF DSPFFD-REC.
           MOVE     "PTMPFFD"       TO OUTFILE  OF DSPFFD-REC.
           MOVE     "QTEMP"         TO OUTLIB   OF DSPFFD-REC.
           CALL     "CLP0043" USING DSPFFD-REC
                                    RET-CODE
           END-CALL.

       CRT-FFD-90.
           EXIT.
      /
     �*---------------------------------------------------------------
     �* COPY-PGM-INIT/COPY-PGM-EXIT: STANDARDROUTINEN START UND ENDE
     �*---------------------------------------------------------------

           COPY     PGMWRK     OF APG-QCPYSRC.
      /
