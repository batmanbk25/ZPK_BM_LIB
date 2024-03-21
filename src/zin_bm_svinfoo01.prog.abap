*&---------------------------------------------------------------------*
*&  Include           ZIN_BM_SVINFOO01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'ZGS_100'.
  SET TITLEBAR 'ZGT_100'.

  CALL FUNCTION 'ZFM_SCR_PBO'
    EXPORTING
      I_SET_LIST_VALUES         = 'X'
      I_SET_LIST_DEFAULT        = 'X'.

  PERFORM 0100_PBO.

ENDMODULE.                 " STATUS_0100  OUTPUT
