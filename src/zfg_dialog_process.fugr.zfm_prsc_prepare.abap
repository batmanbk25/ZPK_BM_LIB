FUNCTION ZFM_PRSC_PREPARE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_REPID) TYPE  REPID DEFAULT SY-CPROG
*"     REFERENCE(I_DYNNR) TYPE  DYNNR DEFAULT SY-DYNNR
*"--------------------------------------------------------------------
CALL FUNCTION 'ZFM_PRSC_EXE_SUBROUTINES'
    EXPORTING
      I_REPID        = I_REPID
      I_DYNNR        = I_DYNNR
      I_EVTYPE       = GC_EVTYPE_INIT.





ENDFUNCTION.
