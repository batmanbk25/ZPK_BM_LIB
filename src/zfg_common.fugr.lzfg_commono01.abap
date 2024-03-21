*----------------------------------------------------------------------*
***INCLUDE LZFG_COMMONO01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  IF GO_CHART_TIMER IS BOUND.
    SET PF-STATUS 'ZGS_110'.
  ELSE.
    SET PF-STATUS 'ZGS_100'.
  ENDIF.
*  SET TITLEBAR 'xxx'.
  CALL METHOD GO_CHART_ENGINE->RENDER.
ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0101 OUTPUT.
  IF GO_CHART_TIMER IS BOUND.
    SET PF-STATUS 'ZGS_110'.
  ELSE.
    SET PF-STATUS 'ZGS_100'.
  ENDIF.

ENDMODULE.                 " STATUS_0101  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS 'ZGS_200'.
  SET TITLEBAR 'ZGT_200'.

*  PERFORM 200_NEST_DATA_VIEW.

ENDMODULE.                 " STATUS_0200  OUTPUT
