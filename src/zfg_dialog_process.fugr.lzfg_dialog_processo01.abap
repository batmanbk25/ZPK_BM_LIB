*----------------------------------------------------------------------*
***INCLUDE LZFG_DIALOG_PROCESSO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'ZGS_100'.
  SET TITLEBAR 'ZGT_100'.
  PERFORM 100_PBO.
ENDMODULE.                 " STATUS_0100  OUTPUT