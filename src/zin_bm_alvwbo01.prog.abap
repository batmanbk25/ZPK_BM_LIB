*&---------------------------------------------------------------------*
*&  Include           ZIN_BM_ALVWBO01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'ZGS_100'.
  SET TITLEBAR 'ZGT_100' WITH GS_PROG-REPID.

  PERFORM 0100_PBO.
ENDMODULE.                 " STATUS_0100  OUTPUT