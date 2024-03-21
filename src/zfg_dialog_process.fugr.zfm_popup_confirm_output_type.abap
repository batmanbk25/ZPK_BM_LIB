FUNCTION ZFM_POPUP_CONFIRM_OUTPUT_TYPE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_EXCEL) TYPE  XMARK DEFAULT 'X'
*"     REFERENCE(I_SMARTFORM) TYPE  XMARK DEFAULT 'X'
*"     REFERENCE(I_ALV) TYPE  XMARK DEFAULT 'X'
*"  EXPORTING
*"     REFERENCE(E_ANSWER) TYPE  C
*"--------------------------------------------------------------------
ZST_BM_OUTTYP-SMF_DIS = I_SMARTFORM.
  ZST_BM_OUTTYP-EXC_DIS = I_EXCEL.
  ZST_BM_OUTTYP-ALV_DIS = I_ALV.
  CALL SCREEN 100 STARTING AT 10 10.
  CASE GC_XMARK.
    WHEN ZST_BM_OUTTYP-SMF.
      E_ANSWER = '1'.
    WHEN ZST_BM_OUTTYP-EXC.
      E_ANSWER = '2'.
    WHEN ZST_BM_OUTTYP-ALV.
      E_ANSWER = '3'.
    WHEN OTHERS.
      E_ANSWER = 'A'.
  ENDCASE.





ENDFUNCTION.
