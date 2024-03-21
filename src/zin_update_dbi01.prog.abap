*&---------------------------------------------------------------------*
*&  Include           ZIN_UPDATE_DBI01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM LEAVE.
    WHEN 'PROCESS'.
      PERFORM BUILD_WHERE_CLAUSE.
      PERFORM GET_DATA.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  UPDATE_TABLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE UPDATE_TABLE INPUT.
  CASE SY-UCOMM.
    WHEN 'SHOWALL'.
      CLEAR GS_FIELD-NO_OUT.
    WHEN 'HIDEALL'.
      GS_FIELD-NO_OUT = 'X'.
  ENDCASE.
  MODIFY GT_FIELDS FROM GS_FIELD INDEX TAB_SEL_FIELDS-CURRENT_LINE.
ENDMODULE.                 " UPDATE_TABLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM LEAVE.
    WHEN 'SAVE'.
      PERFORM SAVE_DATA.
    WHEN 'DEL_ALL'.
      PERFORM DELETE_ALL.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
