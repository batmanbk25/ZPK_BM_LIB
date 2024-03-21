FUNCTION ZFM_SCR_INIT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_CPROG) TYPE  CPROG DEFAULT SY-CPROG
*"     REFERENCE(I_DYNNR) TYPE  DYNNR DEFAULT SY-DYNNR
*"     VALUE(I_CONFIG_PROG) TYPE  SY-REPID OPTIONAL
*"--------------------------------------------------------------------

  CALL FUNCTION 'ZFM_SCR_PAI'
   EXPORTING
      I_CPROG         = I_CPROG
      I_DYNNR         = I_DYNNR
      I_AUTO_STOP     = SPACE
      I_INITIAL       = GC_XMARK
      I_CONFIG_PROG   = I_CONFIG_PROG.

ENDFUNCTION.
