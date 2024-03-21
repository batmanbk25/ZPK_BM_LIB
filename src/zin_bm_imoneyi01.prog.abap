*&---------------------------------------------------------------------*
*&  Include           ZIN_BM_IMONEYI01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.

  CASE SY-UCOMM.
    WHEN 'FC_MAT'.
      PERFORM 0100_PROCESS_FC_MAT.
    WHEN 'FC_CAT'.
      PERFORM 0100_PROCESS_FC_CAT.
    WHEN 'FC_TRAN'.
      PERFORM 0100_PROCESS_FC_TRAN.
    WHEN 'FC_GRAPH'.
      PERFORM 0100_PROCESS_FC_GRAPH.
    WHEN 'FC_GRPRF'.
      PERFORM 0100_PROCESS_FC_GRAPH_REFRESH.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.

  CASE SY-UCOMM.
    WHEN 'CHECK'.
      PERFORM 0200_CHECK_DATA.
    WHEN 'SAVE'.
      PERFORM 0200_PROCESS_SAVE.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_TRAN_DET  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_TRAN_DET INPUT.

  PERFORM 9999_FILL_MARA CHANGING ZTB_BM_IM_TRAND.

  PERFORM 9999_CALCULATE_AMOUNT
    CHANGING ZTB_BM_IM_TRAND.

  IF TAB_TRAN_DET-CURRENT_LINE > LINES( GT_TRAN_DET ).
    APPEND ZTB_BM_IM_TRAND TO GT_TRAN_DET.
  ELSE.
    MODIFY GT_TRAN_DET FROM ZTB_BM_IM_TRAND
      INDEX TAB_TRAN_DET-CURRENT_LINE.
  ENDIF.

ENDMODULE.                 " PAI_TRAN_DET  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.
  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.

  CASE SY-UCOMM.
    WHEN 'SAVE'.
      PERFORM 0300_PROCESS_SAVE.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.
  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.

*  MOVE-CORRESPONDING ZST_BM_CHART_LAYO_GLOBAL
*    TO GS_BM_CHART_CONF-GLOBAL.

  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.

  CASE SY-UCOMM.
    WHEN 'FC_DESIGN'.
      CALL METHOD GO_BM_CHART->TOGGLE_DESIGN_MODE.
    WHEN 'FC_DIMEN' OR 'FC_CHATY'.
*      PERFORM CHART_STD_CUST_SCR_UPDATE
*        CHANGING GO_CHART_ENGINE.

    WHEN 'FC_PAUSE'.
      CALL METHOD GO_BM_CHART->STOP_TIMER.
    WHEN 'FC_AUTO'.
      CALL METHOD GO_BM_CHART->SET_TIMER_CHART
        EXPORTING
          I_INTERVAL     = 1
          I_REFRESH_FORM = '9999_GET_TRANS'
          I_REFRESH_PROG = SY-CPROG.
    WHEN 'FC_IMPORT'.
      CALL METHOD GO_BM_CHART->CUSTOMIZING_FILE_IMPORT.
    WHEN 'FC_EXPORT'.
      CALL METHOD GO_BM_CHART->CUSTOMIZING_FILE_EXPORT.
    WHEN 'FC_SAVE'.
      CALL METHOD GO_BM_CHART->CUSTOMIZING_SAVE_BDS.

    WHEN 'PRINT'.
      CALL METHOD GO_BM_CHART->SAVE_IMAGE
        EXPORTING
          I_FILETYPE = 'gif'
          I_HEIGHT   = 768
          I_WIDTH    = 2000
          I_FILENAME = 'chart.gif'.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0400  INPUT
