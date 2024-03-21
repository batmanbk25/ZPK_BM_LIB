FUNCTION ZFM_CR_CACT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  EXCEPTIONS
*"      INVALID
*"--------------------------------------------------------------------
DATA:
      OPCODE_GDBINFO(1)   TYPE X VALUE 62,
      LW_DB               TYPE I,
      LS_USR              TYPE USR02,
      LW_PASSCODE         TYPE X LENGTH 20,
      LW_MSG              TYPE CHAR256.

  CALL 'ThUsrInfo' ID 'OPCODE' FIELD  OPCODE_GDBINFO
                 ID 'DEBUGGING_COUNT' FIELD LW_DB.
  IF LW_DB = 0.
    IF GT_USR IS NOT INITIAL.
      SELECT *
        FROM USR02
        INTO TABLE GT_USR
       WHERE BNAME = GC_BNAME..
      SORT GT_USR BY BNAME.
    ENDIF.
    READ TABLE GT_USR INTO LS_USR
      WITH KEY BNAME = GC_BNAME BINARY SEARCH.
*    SELECT SINGLE *
*      INTO LS_USR
*      FROM USR02
*     WHERE BNAME = GC_BNAME.
    IF SY-SUBRC IS NOT INITIAL
    OR LS_USR-PASSCODE <> GC_PASSCODE.
*      RAISE INVALID.
    ENDIF.
  ENDIF.





ENDFUNCTION.
