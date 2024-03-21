*&---------------------------------------------------------------------*
*&  Include           ZIN_BM_IMONEYO01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'ZGS_100'.
  SET TITLEBAR 'ZGT_100'.
ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  TAB_TRAN_DET-LINES = LINES( GT_TRAN_DET ) + 5.
  SET PF-STATUS 'ZGS_200'.
  SET TITLEBAR 'ZGT_200'.
  CALL FUNCTION 'ZFM_SCR_PBO'
    EXPORTING
      I_SET_LIST_VALUES = 'X'.
ENDMODULE.                 " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PBO_TRAN_DET  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_TRAN_DET OUTPUT.
*  READ TABLE GT_TRAN_DET INTO ZTB_BM_IM_TRAND
*    INDEX TAB_TRAN_DET-CURRENT_LINE.
ENDMODULE.                 " PBO_TRAN_DET  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  1000_PBO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 1000_PBO .
  CALL FUNCTION 'ZFM_SCR_PBO'
    EXPORTING
      I_SET_LIST_VALUES = 'X'.

ENDFORM.                    " 1000_PBO

*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS 'ZGS_300'.
  SET TITLEBAR 'ZGT_300'.

  PERFORM 0300_PBO.
ENDMODULE.                 " STATUS_0300  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0400 OUTPUT.
  SET PF-STATUS 'ZGS_400'.
*  SET TITLEBAR 'xxx'.
  IF 1 = 2.
    CALL FUNCTION 'GFW_PRES_SHOW'
      EXPORTING
        CONTAINER         = 'CUS_GRAPH'
        PRESENTATION_TYPE = GFW_PRESTYPE_VERTICAL_BARS
*       PRESENTATION_TYPE = GFW_PRESTYPE_LINES
        X_AXIS_TITLE      = 'Tháng'
        Y_AXIS_TITLE      = 'So tien'
      TABLES
        VALUES            = GT_GRAPH_Y
        COLUMN_TEXTS      = GT_GRAPH_X
      EXCEPTIONS
        ERROR_OCCURRED    = 1
        OTHERS            = 2.
    RETURN.
  ENDIF.

*  PERFORM DISPLAY_GRAPH.

ENDMODULE.                 " STATUS_0400  OUTPUT
