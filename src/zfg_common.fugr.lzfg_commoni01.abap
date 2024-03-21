*----------------------------------------------------------------------*
***INCLUDE LZFG_COMMONI01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  MOVE-CORRESPONDING ZST_BM_CHART_LAYO_GLOBAL
    TO GS_BM_CHART_CONF-GLOBAL.

  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.

  CASE SY-UCOMM.
    WHEN 'FC_DESIGN'.
      PERFORM 0100_PROCESS_FC_DESIGN.

    WHEN 'FC_DIMEN' OR 'FC_CHATY'.
      PERFORM CHART_STD_CUST_SCR_UPDATE
        CHANGING GO_CHART_ENGINE.

    WHEN 'FC_PAUSE'.
      GO_CHART_HANDLE->AUTORUN = SPACE.
      CALL METHOD GO_CHART_TIMER->RUN.

    WHEN 'FC_AUTO'.
      GO_CHART_HANDLE->AUTORUN = ABAP_TRUE.
      CALL METHOD GO_CHART_TIMER->RUN.

    WHEN 'FC_EXPORT'.
      PERFORM 0100_PROCESS_FC_EXPORT.

    WHEN 'FC_SAVE'.
      PERFORM 0100_PROCESS_FC_SAVE_CUST.

    WHEN 'FC_LOAD'.
      PERFORM 0100_PROCESS_FC_LOAD.

    WHEN 'PRINT'.
      PERFORM 0100_PROCESS_FC_PRINT.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0101 INPUT.

  MOVE-CORRESPONDING ZST_BM_CHART_LAYO_GLOBAL
    TO GS_BM_CHART_CONF-GLOBAL.

  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.

  CASE SY-UCOMM.
    WHEN 'FC_DESIGN'.
      CALL METHOD GO_BM_CHART->TOGGLE_DESIGN_MODE.
    WHEN 'FC_DIMEN' OR 'FC_CHATY'.
      PERFORM CHART_STD_CUST_SCR_UPDATE
        CHANGING GO_CHART_ENGINE.

    WHEN 'FC_PAUSE'.
      GO_CHART_HANDLE->AUTORUN = SPACE.
      CALL METHOD GO_CHART_TIMER->RUN.

    WHEN 'FC_AUTO'.
      GO_CHART_HANDLE->AUTORUN = ABAP_TRUE.
      CALL METHOD GO_CHART_TIMER->RUN.

    WHEN 'FC_EXPORT'.
      CALL METHOD GO_BM_CHART->CUSTOMIZING_FILE_EXPORT.
    WHEN 'FC_SAVE'.
      CALL METHOD GO_BM_CHART->CUSTOMIZING_SAVE_BDS.
    WHEN 'FC_LOAD'.
      CALL METHOD GO_BM_CHART->CUSTOMIZING_FILE_IMPORT.

    WHEN 'PRINT'.
      CALL METHOD GO_BM_CHART->SAVE_IMAGE
        EXPORTING
          I_FILETYPE = 'PNG'
          I_HEIGHT   = 768
          I_WIDTH    = 1024
          I_FILENAME = 'chart.png'.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0101  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

* Free objects
  PERFORM 9999_NEST_FREE_OBJECTS.

* Process function codes
  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
