*----------------------------------------------------------------------*
***INCLUDE LZFG_BDSI01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  F4_FILENAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_FILENAME INPUT.
  PERFORM F4_FILENAME.

ENDMODULE.                 " F4_FILENAME  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE SY-UCOMM.
    WHEN 'FC_IMPORT'.
      PERFORM SAVE_IMG.
    WHEN 'OK'.
      CALL METHOD GO_PIC_NEW->CLEAR_PICTURE.
      CALL METHOD GO_PIC_OLD->CLEAR_PICTURE.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      CALL METHOD GO_PIC_NEW->CLEAR_PICTURE.
      CALL METHOD GO_PIC_OLD->CLEAR_PICTURE.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0200  INPUT
