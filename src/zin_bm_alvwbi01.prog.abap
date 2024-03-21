*&---------------------------------------------------------------------*
*&  Include           ZIN_BM_ALVWBI01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.

  CASE SY-UCOMM.
    WHEN GC_FC_SAVE.
      PERFORM 0100_PROCESS_SAVE.
*    WHEN .
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
