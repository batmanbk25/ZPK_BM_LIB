FUNCTION ZFM_EXCEL_SPL_CONFID_TO_FORMAT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_CONFIG)
*"  EXPORTING
*"     REFERENCE(E_CELL_FORMAT) TYPE  ZST_CELLS_FORMAT
*"     REFERENCE(E_CELL_INITIAL) TYPE  MARK
*"--------------------------------------------------------------------
CHECK I_CONFIG IS NOT INITIAL.
CLEAR E_CELL_INITIAL.

DATA: ACBDEFGHIJ(10)      TYPE C,
      A(1),B(1),C(1),D(1) TYPE C,
      EF(2),GH(2),IJ(2)   TYPE C,
      LS_CF               TYPE ZST_CELLS_FORMAT,
      LW_INT              TYPE INT4,
      I TYPE I.
  i = 1231231.
  ACBDEFGHIJ = I_CONFIG.
  A  = ACBDEFGHIJ(1).
  B  = ACBDEFGHIJ+1(1).
  C  = ACBDEFGHIJ+2(1).
  D  = ACBDEFGHIJ+3(1).
  EF = ACBDEFGHIJ+4(2).
  GH = ACBDEFGHIJ+6(2).
  IJ = ACBDEFGHIJ+8(2).

  CASE A. " Bold
    WHEN '1'.   LS_CF-BOLD = 1.   " Bold
    WHEN '0'.   LS_CF-BOLD = 0.   " Not Bold
    WHEN OTHERS.LS_CF-BOLD = -1.  " Not change
  ENDCASE.
  CASE B. " Italic
    WHEN '1'.   LS_CF-ITALIC = 1. " Italic
    WHEN '0'.   LS_CF-ITALIC = 0. " Not Italic
    WHEN OTHERS.LS_CF-ITALIC = -1." Not change
  ENDCASE.
  CASE C. " Alignment
    WHEN '1'.   LS_CF-ALIGN = 1.  " Center
    WHEN '0'.   LS_CF-ALIGN = 0.  " Right
    WHEN '2'.   LS_CF-ALIGN = 2.  " Left
    WHEN OTHERS.LS_CF-ALIGN = -1. " Not change
  ENDCASE.
  CASE D. " Font
    WHEN 'A' OR 'a'.   LS_CF-FONT = 'Arial'.
    WHEN 'C' OR 'c'.   LS_CF-FONT = 'Courier New'.
    WHEN 'T' OR 't'.   LS_CF-FONT = 'Times New Roman'.
    WHEN OTHERS. CLEAR LS_CF-FONT.
  ENDCASE.

" Size
  CLEAR LW_INT.
  TRY.
    LW_INT = EF.
    IF 8 <= LW_INT AND LW_INT <= 72.
      LS_CF-SIZE = LW_INT.
    ENDIF.
  CATCH CX_ROOT.
  ENDTRY.

" Text color
  CLEAR LW_INT.
  TRY.
    LW_INT = GH.
    IF 1 <= LW_INT AND LW_INT <= 56.
      LS_CF-FRONT = LW_INT.
    ENDIF.
  CATCH CX_ROOT.
  ENDTRY.

" Background color
  CLEAR LW_INT.
  TRY.
    LW_INT = IJ.
    IF 1 <= LW_INT AND LW_INT <= 56.
      LS_CF-BACK = LW_INT.
    ENDIF.
  CATCH CX_ROOT.
  ENDTRY.
  E_CELL_FORMAT = LS_CF.
  CLEAR LS_CF.

  CALL FUNCTION 'ZFM_EXCEL_SPL_CHECK_INITAIL'
    EXPORTING
      I_CELL_FORMAT        = E_CELL_FORMAT
    IMPORTING
      E_CELL_INITIAL       = E_CELL_INITIAL.





ENDFUNCTION.
