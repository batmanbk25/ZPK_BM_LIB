FUNCTION ZFM_PRSC_EXE_SUBROUTINES.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_REPID) TYPE  REPID
*"     REFERENCE(I_DYNNR) TYPE  DYNNR
*"     REFERENCE(I_EVTYPE) TYPE  ZDD_PROG_EVTYPE
*"--------------------------------------------------------------------
DATA:
    LS_PROG_FLOW     TYPE ZTB_PROG_FLOW.

  IF GT_PROG_FLOW IS INITIAL.
    SELECT *
      FROM ZTB_PROG_FLOW
      INTO TABLE GT_PROG_FLOW
     WHERE REPID = I_REPID
       AND DISABLED = SPACE.
  ENDIF.

  LOOP AT GT_PROG_FLOW INTO LS_PROG_FLOW
    WHERE DYNNR       = I_DYNNR
      AND EVENTTYPE   = I_EVTYPE.
    PERFORM (LS_PROG_FLOW-SUBROUTINE) IN PROGRAM (I_REPID) IF FOUND.
  ENDLOOP.





ENDFUNCTION.
