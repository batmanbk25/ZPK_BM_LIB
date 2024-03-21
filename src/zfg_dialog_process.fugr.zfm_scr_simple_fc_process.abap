FUNCTION ZFM_SCR_SIMPLE_FC_PROCESS.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_OKCODE) TYPE  SYUCOMM DEFAULT SY-UCOMM
*"     REFERENCE(I_DYNNR) TYPE  DYNNR DEFAULT '0'
*"  CHANGING
*"     REFERENCE(C_OKCODE) TYPE  SYUCOMM OPTIONAL
*"--------------------------------------------------------------------
DATA P_OKCODE TYPE SYUCOMM.

  IF I_OKCODE IS INITIAL.
    P_OKCODE = C_OKCODE.
  ELSE.
    P_OKCODE = I_OKCODE.
  ENDIF.
  CLEAR C_OKCODE.
  CASE P_OKCODE.
    WHEN 'BACK'.
      LEAVE TO SCREEN I_DYNNR.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN SY-DYNNR.
  ENDCASE.





ENDFUNCTION.
