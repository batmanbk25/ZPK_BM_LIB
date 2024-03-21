FUNCTION ZFM_PRSC_CALL_SCREEN.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_REPID) TYPE  REPID DEFAULT SY-CPROG
*"     REFERENCE(I_DYNNR) TYPE  DYNNR DEFAULT SY-DYNNR
*"--------------------------------------------------------------------
PERFORM CALL_SCREEN IN PROGRAM (I_REPID)
    USING I_DYNNR IF FOUND.





ENDFUNCTION.
