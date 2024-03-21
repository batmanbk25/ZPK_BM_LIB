*----------------------------------------------------------------------*
***INCLUDE LZFG_MCBAI01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CALL METHOD GO_ALV_TABINP->CHECK_CHANGED_DATA.

  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.
  CASE SY-UCOMM.
    WHEN 'FC_IMPSTD'.
      PERFORM 0100_PROCESS_FC_IMPSTD.

    WHEN 'SAVE'.
      PERFORM 0100_PROCESS_FC_SAVE.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  9999_SET_FILENAME_AND_IMPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  FIELDS        Fields to update
*  <--  ERROR         Errors
*----------------------------------------------------------------------*
FORM 9999_SET_FILENAME_AND_IMPORT
  TABLES   FIELDS STRUCTURE SVAL
  CHANGING ERROR  STRUCTURE SVALE.

  DATA:
    LS_FIELD 	      TYPE SVAL,
    LS_RCGFILETR    TYPE ZST_ICL_WC_FILE.
  FIELD-SYMBOLS:
    <LF_UPDTAB>     TYPE ANY,
    <LF_FIELD>      TYPE ANY.

  LOOP AT FIELDS INTO LS_FIELD WHERE VALUE IS NOT INITIAL.
    ASSIGN COMPONENT LS_FIELD-FIELDNAME OF STRUCTURE LS_RCGFILETR
      TO <LF_FIELD>.
    IF SY-SUBRC IS INITIAL.
      <LF_FIELD> = LS_FIELD-VALUE.
    ENDIF.
  ENDLOOP.

  PERFORM 9999_IMPORT_FILE
    USING LS_RCGFILETR.

ENDFORM.                    " 9999_SET_FILENAME_AND_IMPORT
