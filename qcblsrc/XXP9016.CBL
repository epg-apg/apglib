       IDENTIFICATION DIVISION.
     �*
         PROGRAM-ID.              XXP9016.
           COPY COPYRIGHT  OF APG-QCPYSRC.
     �*
     �*---------------------------------------------------------------*
     �* TESTEN DER BERECHTIGUNGSPR�FUNG                               *
     �*---------------------------------------------------------------*
     �*                                                               *
     �* AUTOR         :  A. PIEGER                                    *
     �*                                                               *
     �* ERSTELLT AM   :  08.07.2010                                   *
     �*                                                               *
     �* FUNKTION      :  TEST-PGM                                     *
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
           COPY WRKSTD     OF APG-QCPYSRC.

       01  PGM-WRK                       PIC X(10) VALUE "XXP9016".
       01  PGM-TYP                       PIC X(8)  VALUE "TEST".

       01  TEST-VAR                      PIC X(50).
       01  TEST-VAR2                     PIC X(50).
       01  TEST-VAR3                     PIC X(50).
      /
     �*-------------------------------------------------------------
       LINKAGE SECTION.
     �*-------------------------------------------------------------
       PROCEDURE DIVISION.
     �*-------------------------------------------------------------
       STEUER SECTION.
       ANFANG.

     �* F�LLEN PGM-WRK UND AUSF�HREN STANDARDROUTINEN
           MOVE     "XXP9016"   TO PGM-WRK.
           PERFORM  COPY-PGM-INIT.

           INITIALIZE TEST-VAR2, TEST-VAR3.
           MOVE     "�asdasdasd�asdaasdasd�asdasda" TO TEST-VAR2.
           MOVE     FUNCTION UPPER-CASE(TEST-VAR2) TO TEST-VAR3.

           INITIALIZE TEST-VAR.
           MOVE     "�LAHIZZU��ASDASD6SADA&DA�SAD�" TO TEST-VAR.
           INSPECT  TEST-VAR CONVERTING "����&" TO "UOASU".

       ENDE.
           PERFORM  COPY-PGM-EXIT.

           GOBACK.
      /
     �*---------------------------------------------------------------
     �* COPY-PGM-INIT/COPY-PGM-EXIT: STANDARDROUTINEN START UND ENDE
     �*---------------------------------------------------------------

           COPY     PGMWRK     OF APG-QCPYSRC.
      /
