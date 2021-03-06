       IDENTIFICATION DIVISION.
     �*
         PROGRAM-ID.              CFP9200.
     �*
     �*---------------------------------------------------------------*
     �* ZENTRALE POINTERVERWALTUNG                                    *
     �*---------------------------------------------------------------*
     �*                                                               *
     �* AUTOR         :  A. PIEGER                                    *
     �*                                                               *
     �* ERSTELLT AM   :  28.05.2010                                   *
     �*                                                               *
     �* FUNKTION      :  POINTERVERWALTUNG                            *
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

     �* STANDARDFELDER CL-PROGRAMME
           COPY WRKPGMPARM  OF APG-QCPYSRC.

       01  PGM-WRK                       PIC X(10) VALUE "CFP9200".
       01  PGM-TYP                       PIC X(8)  VALUE "CONFIG".

       01  WRK-PTR                       USAGE POINTER.
       01  WRK-RED                       REDEFINES WRK-PTR PIC X(160).

       01  IMP-PTR                       USAGE POINTER.
       01  IMP-RED                       REDEFINES IMP-PTR PIC X(160).
      /
     �*-------------------------------------------------------------
       LINKAGE SECTION.
       01  X-MAIN-PTR                    USAGE POINTER.
       01  X-RETURN-PTR                  USAGE POINTER.
       01  X-PTR-ID                      LIKE MAP-MAIN-ID.
       01  X-PTR-ACTION                  LIKE MAP-MAIN-ACTION.
       01  X-MAPDTA-REC                  LIKE MAPDTA-REC.
       01  X-RETCODE                     LIKE RET-CODE.
     �*-------------------------------------------------------------
       PROCEDURE DIVISION USING X-MAIN-PTR
                                X-RETURN-PTR
                                X-PTR-ID
                                X-PTR-ACTION
                                X-MAPDTA-REC
                                X-RETCODE.
     �*-------------------------------------------------------------
       STEUER SECTION.
       ANFANG.

     �* F�LLEN PGM-WRK
           MOVE     "CFP9200 " TO PGM-WRK.
           PERFORM  COPY-PGM-INIT.

     �* WRK-POINTER INITIALISIEREN
           SET      WRK-PTR TO NULL.
           SET      IMP-PTR TO NULL.

     �* NOCH KEIN MAIN-POINTER VORHANDEN, DANN EINEN GENERIEREN
           IF       X-MAIN-PTR = NULL
                    PERFORM GET-POINTER
                    SET X-MAIN-PTR TO WRK-PTR
           END-IF.

     �* GGF. DEN �BERGEGEBENEN POINTER RETTEN
           INITIALIZE MAPDTA-REC.
           MOVE     X-MAPDTA-REC TO MAPDTA-REC.
           SET      IMP-PTR TO MAP-PTR OF MAPDTA-REC.

           EVALUATE X-PTR-ACTION
     �*�            EINTRAG:�NEUEN EINTRAG SCHREIBEN
                    WHEN "ETR:WRITE"
                         PERFORM ENTRY-WRITE
     �*            �EINTRAG:�VORHANDENEN EINTRAG LESEN
                    WHEN "ETR:READ"
                         PERFORM ENTRY-READ
                    WHEN "ETR:READLFDN"
                         PERFORM ENTRY-READ-LFDN
     �*            �EINTRAG:�VORHANDENEN EINTRAG L�SCHEN
                    WHEN "ETR:DELETE"
                         PERFORM ENTRY-DELETE
     �*            �POINTEREBENE:�POINTER HINZUF�GEN
                    WHEN "PTR:ADD"
                         PERFORM POINTER-ADD
     �*            �POINTEREBENE:�EINEN POINTER ZUR�CKGEBEN
                    WHEN "PTR:GET"
                    WHEN "PTR:RETURN"
                         PERFORM POINTER-RETURN
     �*            �POINTEREBENE:�POINTER SORTIEREN
                    WHEN "PTR:SORT"
                         PERFORM POINTER-SORT
     �*            �POINTEREBENE:�GANZEN POINTER CLEAREN UND EINTRAG
     �*                           L�SCHEN
                    WHEN "PTR:CLEAR"
                         PERFORM POINTER-CLEAR-ONE
     �*            �POINTEREBENE:�ALLE POINTER-EINTR�GE L�SCHEN
                    WHEN "PTR:CLEARALL"
                         PERFORM POINTER-CLEAR-ALL
           END-EVALUATE.

       ENDE.

           PERFORM  COPY-PGM-EXIT.

           GOBACK.
      /
     �*--------------------------------------------------------------
     �* DEM CHILD-POINTER EINEN EINTRAG HINZUF�GEN
     �*--------------------------------------------------------------
       ENTRY-WRITE SECTION.
       ENT-WRT-00.

     �* MIT MAPDTA PR�FEN OB ES DEN EINTRAG GIBT
           PERFORM  CHECK-MAIN-ID.
           IF       RET-CODE = SPACES
     �*             NEUEN MAPDTA-EINTRAG F�R BESTEHENDEN POINTER
     �*             EINTRAGEN
                    INITIALIZE MAPDTA-REC
                    MOVE    X-MAPDTA-REC TO MAPDTA-REC
                    MOVE    MAP-WRITE    TO MAP-ACT OF MAPDTA-REC
                    SET     MAP-PTR OF MAPDTA-REC TO WRK-PTR
                    PERFORM COPY-CALL-MAPDTA
           ELSE
     �*             NEUEN MAPDTA-EINTRAG F�R NEUEN POINTER
     �*             EINTRAGEN UND ZUM MAIN-PTR EINTRAGEN
                    INITIALIZE MAPDTA-REC
                    MOVE    X-MAPDTA-REC TO MAPDTA-REC
                    MOVE    MAP-WRITE    TO MAP-ACT OF MAPDTA-REC
                    SET     MAP-PTR OF MAPDTA-REC TO NULL
                    PERFORM COPY-CALL-MAPDTA
                    SET  WRK-PTR TO MAP-PTR OF MAPDTA-REC
                    IF   RET-CODE = SPACES
                         PERFORM ADD-MAIN-PTR
                    END-IF
           END-IF.

     �* R�CKGABE-POINTER F�LLEN
           SET      X-RETURN-PTR TO WRK-PTR.

       ENT-WRT-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* DEM CHILD-POINTER �BER DEN KEY LESEN
     �*--------------------------------------------------------------
       ENTRY-READ SECTION.
       ENT-REA-00.

     �* MIT MAPDTA PR�FEN OB ES DEN EINTRAG GIBT
           PERFORM  CHECK-MAIN-ID.
           IF       RET-CODE = SPACES
     �*             POINTER LESEN
                    INITIALIZE MAPDTA-REC
                    MOVE    X-MAPDTA-REC TO MAPDTA-REC
                    MOVE    MAP-READ     TO MAP-ACT OF MAPDTA-REC
                    SET     MAP-PTR OF MAPDTA-REC TO WRK-PTR
                    PERFORM COPY-CALL-MAPDTA
                    IF   RET-CODE = SPACES
                         MOVE MAPDTA-REC TO X-MAPDTA-REC
                    END-IF
     �*             R�CKGABE-POINTER F�LLEN
                    SET     X-RETURN-PTR TO WRK-PTR
           END-IF.

       ENT-REA-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* DEM CHILD-POINTER �BER DIE LFDN LESEN
     �*--------------------------------------------------------------
       ENTRY-READ-LFDN SECTION.
       ENT-REF-00.

     �* MIT MAPDTA PR�FEN OB ES DEN EINTRAG GIBT
           PERFORM  CHECK-MAIN-ID.
           IF       RET-CODE = SPACES
     �*             POINTER LESEN
                    INITIALIZE MAPDTA-REC
                    MOVE    X-MAPDTA-REC  TO MAPDTA-REC
                    MOVE    MAP-READ-LFDN TO MAP-ACT OF MAPDTA-REC
                    SET     MAP-PTR OF MAPDTA-REC TO WRK-PTR
                    PERFORM COPY-CALL-MAPDTA
                    IF   RET-CODE = SPACES
                         MOVE MAPDTA-REC TO X-MAPDTA-REC
                    END-IF
     �*             R�CKGABE-POINTER F�LLEN
                    SET     X-RETURN-PTR TO WRK-PTR
           END-IF.

       ENT-REF-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* DEM CHILD-POINTER EINEN EINTRAG L�SCHEN
     �*--------------------------------------------------------------
       ENTRY-DELETE SECTION.
       ENT-DEL-00.

     �* MIT MAPDTA PR�FEN OB ES DEN EINTRAG GIBT
           PERFORM  CHECK-MAIN-ID.
           IF       RET-CODE = SPACES
     �*             POINTER LESEN
                    INITIALIZE MAPDTA-REC
                    MOVE    X-MAPDTA-REC TO MAPDTA-REC
                    MOVE    MAP-DELETE   TO MAP-ACT OF MAPDTA-REC
                    SET     MAP-PTR OF MAPDTA-REC TO WRK-PTR
                    PERFORM COPY-CALL-MAPDTA
     �*             R�CKGABE-POINTER F�LLEN
                    SET     X-RETURN-PTR TO WRK-PTR
           END-IF.

       ENT-DEL-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* EINEN SCHON VORHANDENEN POINTER HINZUF�GEN
     �*--------------------------------------------------------------
       POINTER-ADD SECTION.
       PTR-ADD-00.

     �* MIT MAPDTA PR�FEN OB ES DEN EINTRAG GIBT
           PERFORM  CHECK-MAIN-ID.
           IF       RET-CODE NOT = SPACES
     �*             �BERGEBENEN POINTER �BERNEHMEN
                    INITIALIZE MAPDTA-REC
                    MOVE    X-PTR-ID     TO MAP-KEY OF MAPDTA-REC
                    MOVE    IMP-RED      TO MAP-REC OF MAPDTA-REC
                    MOVE    MAP-WRITE    TO MAP-ACT OF MAPDTA-REC
                    SET     MAP-PTR OF MAPDTA-REC TO X-MAIN-PTR
                    PERFORM COPY-CALL-MAPDTA
           END-IF.

     �* R�CKGABE-POINTER F�LLEN
           SET      X-RETURN-PTR TO IMP-PTR.

       PTR-ADD-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* EINEN SCHON VORHANDENEN POINTER HINZUF�GEN
     �*--------------------------------------------------------------
       POINTER-RETURN SECTION.
       PTR-ADD-00.

     �* MIT MAPDTA PR�FEN OB ES DEN EINTRAG GIBT
           PERFORM  CHECK-MAIN-ID.
           IF       RET-CODE NOT = SPACES
                    PERFORM GET-POINTER
                    PERFORM ADD-MAIN-PTR
           END-IF.

     �* R�CKGABE-POINTER F�LLEN
           SET      X-RETURN-PTR TO WRK-PTR.

       PTR-ADD-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* EINEN SCHON VORHANDENEN POINTER SORTIEREN
     �*--------------------------------------------------------------
       POINTER-SORT SECTION.
       PTR-SRT-00.

     �* MIT MAPDTA PR�FEN OB ES DEN EINTRAG GIBT
           PERFORM  CHECK-MAIN-ID.
           IF       RET-CODE = SPACES
     �*             �BERGEBENEN POINTER �BERNEHMEN
                    INITIALIZE MAPDTA-REC
                    MOVE    X-PTR-ID     TO MAP-KEY OF MAPDTA-REC
                    MOVE    MAP-SORT     TO MAP-ACT OF MAPDTA-REC
                    SET     MAP-PTR OF MAPDTA-REC TO WRK-PTR
                    PERFORM COPY-CALL-MAPDTA
           END-IF.

     �* R�CKGABE-POINTER F�LLEN
           SET      X-RETURN-PTR TO IMP-PTR.

       PTR-SRT-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* DEM CHILD-POINTER CLEAREN
     �*--------------------------------------------------------------
       POINTER-CLEAR-ONE SECTION.
       PTR-CLO-00.

     �* MIT MAPDTA PR�FEN OB ES DEN EINTRAG GIBT
           PERFORM  CHECK-MAIN-ID.
           IF       RET-CODE = SPACES
     �*             GANZEN POINTER LEEREN
                    INITIALIZE MAPDTA-REC
                    MOVE    MAP-CLEAR    TO MAP-ACT OF MAPDTA-REC
                    SET     MAP-PTR OF MAPDTA-REC TO WRK-PTR
                    PERFORM COPY-CALL-MAPDTA
                    IF   RET-CODE = SPACES
     �*                  POINTER-EINTRAG IM MAIN-PTR L�SCHEN
                         INITIALIZE MAPDTA-REC
                         MOVE   X-PTR-ID   TO MAP-KEY OF MAPDTA-REC
                         MOVE   MAP-DELETE TO MAP-ACT OF MAPDTA-REC
                         SET    MAP-PTR OF MAPDTA-REC TO X-MAIN-PTR
                         PERFORM COPY-CALL-MAPDTA
                    END-IF
           END-IF.

       PTR-CLO-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* ALLE POINTER LEEREN
     �*--------------------------------------------------------------
       POINTER-CLEAR-ALL SECTION.
       PTR-CLA-00.

           INITIALIZE RET-CODE.

       PTR-CLA-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* EINTRAG ZUM MAIN-PTR EINTRAGEN
     �*--------------------------------------------------------------
       ADD-MAIN-PTR SECTION.
       ADD-MPT-00.

     �* MAIN-STRUCT F�LLEN
           INITIALIZE MAPDTA-REC.
           MOVE     X-PTR-ID        TO MAP-KEY OF MAPDTA-REC.
           MOVE     WRK-RED         TO MAP-REC OF MAPDTA-REC.
           MOVE     MAP-WRITE       TO MAP-ACT OF MAPDTA-REC.
           SET      MAP-PTR OF MAPDTA-REC TO X-MAIN-PTR.
           PERFORM  COPY-CALL-MAPDTA.

       ADD-MPT-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* ERMITTELN EINES POINTERS
     �*--------------------------------------------------------------
       GET-POINTER SECTION.
       GET-PTR-00.

     �* EINEN POINTER ERMITTELN
           INITIALIZE MAPDTA-REC.
           MOVE     MAP-GET-POINTER TO MAP-ACT OF MAPDTA-REC.
           SET      MAP-PTR OF MAPDTA-REC TO NULL.
           PERFORM  COPY-CALL-MAPDTA.
           SET      WRK-PTR TO MAP-PTR OF MAPDTA-REC.

       GET-PTR-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* PR�FEN OB ES DIE ID SCHON GIBT
     �*--------------------------------------------------------------
       CHECK-MAIN-ID SECTION.
       CHK-MID-00.

           INITIALIZE RET-CODE.
     �* POINTER = NULL HEI�T, ES KANN NICHTS GEBEN
           IF       X-MAIN-PTR = NULL
                    MOVE "1" TO RET-CODE
                    GO TO CHK-MID-90
           END-IF.

     �* MIT MAPDTA PR�FEN OB ES DEN EINTRAG GIBT
           INITIALIZE MAPDTA-REC.
           MOVE     X-PTR-ID           TO MAP-KEY OF MAPDTA-REC.
           MOVE     MAP-READ           TO MAP-ACT OF MAPDTA-REC.
           SET      MAP-PTR OF MAPDTA-REC TO X-MAIN-PTR.
           PERFORM  COPY-CALL-MAPDTA.
           IF       RET-CODE = SPACES
                    MOVE MAP-REC OF MAPDTA-REC TO WRK-RED
           END-IF.

       CHK-MID-90.
           EXIT.
      /
     �*---------------------------------------------------------------
     �* COPY-CALL-MAPDTA: MAPDTA AUSF�HREN
     �*---------------------------------------------------------------

           COPY     MAPDTA     OF APG-QCPYSRC.
      /
     �*---------------------------------------------------------------
     �* COPY-PGM-INIT/COPY-PGM-EXIT: STANDARDROUTINEN START UND ENDE
     �*---------------------------------------------------------------

           COPY     PGMWRK     OF APG-QCPYSRC.
      /
