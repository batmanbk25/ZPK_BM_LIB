FUNCTION ZFM_EXCEL_SPL_CHECK_INITAIL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_CELL_FORMAT) TYPE  ZST_CELLS_FORMAT
*"  EXPORTING
*"     REFERENCE(E_CELL_INITIAL) TYPE  MARK
*"--------------------------------------------------------------------
DATA: LS_CF TYPE ZST_CELLS_FORMAT.
LS_CF = I_CELL_FORMAT.
IF    LS_CF-BOLD = -1
  AND LS_CF-ITALIC = -1
  AND LS_CF-ALIGN = -1
  AND LS_CF-FONT IS INITIAL
  AND LS_CF-SIZE IS INITIAL
  AND LS_CF-FRONT IS INITIAL
  AND LS_CF-BACK IS INITIAL.
  E_CELL_INITIAL = 'X'.
ELSE.
  E_CELL_INITIAL = ''.
ENDIF.





ENDFUNCTION.
