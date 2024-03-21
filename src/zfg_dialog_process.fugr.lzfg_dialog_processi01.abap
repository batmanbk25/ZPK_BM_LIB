*----------------------------------------------------------------------*
***INCLUDE LZFG_DIALOG_PROCESSI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE SY-UCOMM.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      CLEAR:  ZST_BM_OUTTYP-SMF,
              ZST_BM_OUTTYP-EXC,
              ZST_BM_OUTTYP-ALV.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
