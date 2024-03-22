*----------------------------------------------------------------------*
***INCLUDE LZFG_PROG_MAINTF01.
*----------------------------------------------------------------------*

**&---------------------------------------------------------------------
*
**&      Form  SAVE_PROG_SIGN
**&---------------------------------------------------------------------
*
**       Save prog sign parameter
**----------------------------------------------------------------------
*
*FORM SAVE_PROG_SIGN .
*  DATA:
*    LT_PROG_SIGNBUK_INS   TYPE TABLE OF ZTB_PROG_SIGNBUK,
*    LS_PROG_SIGNBUK       TYPE ZTB_PROG_SIGNBUK,
*    LW_REGIO              TYPE REGIO,
*    LS_T001               TYPE ZST_T001_USR.
*
*  CLEAR: LT_PROG_SIGNBUK_INS.
*
*  IF GT_PROG_SIGNBUK IS INITIAL.
*    SELECT *
*      FROM ZTB_PROG_SIGNBUK
*      INTO TABLE GT_PROG_SIGNBUK.
*  ENDIF.
*
*  IF GT_T001 IS INITIAL.
*    CALL FUNCTION 'ZFM_VARIANT_GET'
*      EXPORTING
*        I_VAR_NAME        = 'ZREGIO'
*      IMPORTING
*        E_VAR_VALUE       = LW_REGIO
*      EXCEPTIONS
*        NOT_FOUND         = 1
*        OTHERS            = 2.
*
*    SELECT  BUKRS
*            BUTXT
*            REGIO
*            CITY_CODE
*            PRBUK
*            BUKLV
*      FROM T001
*      INTO TABLE GT_T001
*     WHERE REGIO = LW_REGIO.
*  ENDIF.
*
*  ZVI_PROG_SIGN_TOTAL[] = TOTAL[].
*  LOOP AT ZVI_PROG_SIGN_TOTAL.
*    LOOP AT GT_T001 INTO LS_T001.
*      READ TABLE GT_PROG_SIGNBUK TRANSPORTING NO FIELDS
*        WITH KEY  BUKRS   = LS_T001-BUKRS
*                  REPID   = ZVI_PROG_SIGN_TOTAL-REPID
*                  SIGNERF = ZVI_PROG_SIGN_TOTAL-SIGNERF.
*      IF SY-SUBRC IS NOT INITIAL.
*        MOVE-CORRESPONDING ZVI_PROG_SIGN_TOTAL TO LS_PROG_SIGNBUK.
*        LS_PROG_SIGNBUK-BUKRS = LS_T001-BUKRS.
*        APPEND LS_PROG_SIGNBUK TO LT_PROG_SIGNBUK_INS.
*      ENDIF.
*    ENDLOOP.
*  ENDLOOP.
*
*  INSERT ZTB_PROG_SIGNBUK FROM TABLE LT_PROG_SIGNBUK_INS.
*  IF SY-SUBRC IS INITIAL.
*    APPEND LINES OF LT_PROG_SIGNBUK_INS TO GT_PROG_SIGNBUK.
*  ENDIF.
**  COMMIT WORK.
*ENDFORM.                    " SAVE_PROG_SIGN
*
**&---------------------------------------------------------------------
*
**&      Module  BTN_UPIMG  INPUT
**&---------------------------------------------------------------------
*
**       text
**----------------------------------------------------------------------
*
*MODULE BTN_UPIMG INPUT.
*  DATA:
*    LW_LINE     TYPE I,
*    LW_IMGNAME  TYPE TDOBNAME.
*  CHECK SY-UCOMM = 'FC_UPIMG'.
*
*  ZVI_SIGN_POS_BUK_EXTRACT[] = EXTRACT[].
*  GET CURSOR LINE LW_LINE.
**--------------------------------------------------------------------*
*  " Edited by NgocNV8 - 09/10/15
*  LW_LINE = TCTRL_ZVI_SIGN_POS_BUK-TOP_LINE + LW_LINE - 1.
**--------------------------------------------------------------------*
*  READ TABLE ZVI_SIGN_POS_BUK_EXTRACT INDEX LW_LINE.
*
*  CONCATENATE ZVI_SIGN_POS_BUK_EXTRACT-BUKRS
*              ZVI_SIGN_POS_BUK_EXTRACT-SPOSID
*              ZVI_SIGN_POS_BUK_EXTRACT-ITEMIX
*         INTO LW_IMGNAME.
*  CALL FUNCTION 'ZFM_BDS_UPLOAD_IMG'
*    EXPORTING
*      I_IMGNAME       = LW_IMGNAME.
*
*ENDMODULE.                 " BTN_UPIMG  INPUT

*&---------------------------------------------------------------------*
*&      Module  0224_CONDITION_VALUE_SET_DESC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE 0224_CONDITION_VALUE_SET_DESC INPUT.
  PERFORM 0224_CONDITION_VALUE_SET_DESC.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Form 0224_CONDITION_VALUE_SET_DESC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM 0224_CONDITION_VALUE_SET_DESC .
  DATA:
    LS_DIM         TYPE ZTB_BM_COND_DIM,
    LW_WHERE_LANGU TYPE STRING,
    LW_WHERE       TYPE STRING,
    LS_DYNPFIELDS  TYPE DYNPREAD,
    LT_DYNPFIELDS  TYPE TABLE OF DYNPREAD.

  CLEAR: ZVI_BM_COND-LDESC, ZVI_BM_COND-HDESC.
  SELECT SINGLE *
    FROM ZTB_BM_COND_DIM
    INTO LS_DIM
   WHERE TABNAME = ZVI_BM_COND-RTABLE
     AND FIELDNAME = ZVI_BM_COND-RFIELD.
  CHECK SY-SUBRC IS INITIAL
    AND LS_DIM-CHECKTABLE IS NOT INITIAL
    AND LS_DIM-CHECKFIELD IS NOT INITIAL
    AND LS_DIM-DESCF IS NOT INITIAL.

  LW_WHERE = LS_DIM-CHECKFIELD && ' = ''' && ZVI_BM_COND-RLOW && ''''.
  IF LS_DIM-LANGF IS NOT INITIAL.
    CONCATENATE LW_WHERE ' AND ' LS_DIM-LANGF ' = ''' SY-LANGU ''''
           INTO LW_WHERE RESPECTING BLANKS.
  ENDIF.
  SELECT SINGLE (LS_DIM-DESCF)
    FROM (LS_DIM-CHECKTABLE)
    INTO ZVI_BM_COND-LDESC
   WHERE (LW_WHERE).

  LW_WHERE = LS_DIM-CHECKFIELD && ' = ''' && ZVI_BM_COND-RHIGH && ''''.
  IF LS_DIM-LANGF IS NOT INITIAL.
    CONCATENATE LW_WHERE ' AND ' LS_DIM-LANGF ' = ''' SY-LANGU ''''
           INTO LW_WHERE RESPECTING BLANKS. .
  ENDIF.
  SELECT SINGLE (LS_DIM-DESCF)
    FROM (LS_DIM-CHECKTABLE)
    INTO ZVI_BM_COND-HDESC
   WHERE (LW_WHERE).

  GET CURSOR LINE LS_DYNPFIELDS-STEPL.
  LS_DYNPFIELDS-FIELDNAME = 'ZVI_BM_COND-LDESC'.
  LS_DYNPFIELDS-FIELDVALUE = ZVI_BM_COND-LDESC.
  APPEND LS_DYNPFIELDS TO LT_DYNPFIELDS.
  LS_DYNPFIELDS-FIELDNAME = 'ZVI_BM_COND-HDESC'.
  LS_DYNPFIELDS-FIELDVALUE = ZVI_BM_COND-HDESC.
  APPEND LS_DYNPFIELDS TO LT_DYNPFIELDS.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME     = SY-REPID
      DYNUMB     = SY-DYNNR
    TABLES
      DYNPFIELDS = LT_DYNPFIELDS
    EXCEPTIONS
      OTHERS     = 8.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  0224_CONDITION_VALUE_SHLP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE 0224_CONDITION_VALUE_SHLP INPUT.
  PERFORM 0224_CONDITION_VALUE_SHLP.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  0206_CONDITION_VALUE_SHLP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0224_CONDITION_VALUE_SHLP .
  DATA:
    LS_SHLP        TYPE  SHLP_DESCR,
    LW_SCRFIELD    TYPE DYNFNAM,
    LW_TABNAME     TYPE TABNAME,
    LW_FIELDNAME   TYPE FIELDNAME,
    LW_SHLPPARAM   TYPE SHLPFIELD,
    LW_LINE        TYPE I,
    LT_RETURN_VALS TYPE TABLE OF DDSHRETVAL.

  GET CURSOR FIELD LW_SCRFIELD LINE LW_LINE.
  LW_LINE = LW_LINE + TCTRL_ZVI_BM_COND-TOP_LINE - 1.

  READ TABLE EXTRACT INDEX LW_LINE.
  CHECK SY-SUBRC IS INITIAL.
  ZVI_BM_COND = EXTRACT.

  CALL FUNCTION 'F4IF_DETERMINE_SEARCHHELP'
    EXPORTING
      TABNAME           = ZVI_BM_COND-RTABLE
      FIELDNAME         = ZVI_BM_COND-RFIELD
*     SELECTION_SCREEN  = ' '
    IMPORTING
      SHLP              = LS_SHLP
    EXCEPTIONS
      FIELD_NOT_FOUND   = 1
      NO_HELP_FOR_FIELD = 2
      INCONSISTENT_HELP = 3
      OTHERS            = 4.
  CHECK SY-SUBRC IS INITIAL AND LS_SHLP-SHLPNAME IS NOT INITIAL.
  SPLIT LW_SCRFIELD AT '-' INTO LW_TABNAME LW_FIELDNAME.
  READ TABLE LS_SHLP-INTERFACE INTO DATA(LS_INTERFACE)
    WITH KEY VALFIELD = ZVI_BM_COND-RFIELD.
  IF SY-SUBRC IS INITIAL.
    LW_SHLPPARAM = LS_INTERFACE-SHLPFIELD.
  ELSE.
    READ TABLE LS_SHLP-INTERFACE INTO LS_INTERFACE
      WITH KEY F4FIELD = 'X'.
    IF SY-SUBRC IS INITIAL.
      LW_SHLPPARAM = LS_INTERFACE-SHLPFIELD.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME           = LW_TABNAME
      FIELDNAME         = LW_FIELDNAME
      SEARCHHELP        = LS_SHLP-SHLPNAME
      SHLPPARAM         = LW_SHLPPARAM
      DYNPPROG          = SY-REPID
      DYNPNR            = SY-DYNNR
      DYNPROFIELD       = LW_SCRFIELD
    TABLES
      RETURN_TAB        = LT_RETURN_VALS
    EXCEPTIONS
      FIELD_NOT_FOUND   = 1
      NO_HELP_FOR_FIELD = 2
      INCONSISTENT_HELP = 3
      NO_VALUES_FOUND   = 4
      OTHERS            = 5.
  READ TABLE LT_RETURN_VALS INTO DATA(LS_RETVAL)
    WITH KEY RETFIELD = LW_SCRFIELD.
  IF SY-SUBRC IS INITIAL.
    ASSIGN (LW_SCRFIELD) TO FIELD-SYMBOL(<LF_FIELD>).
    <LF_FIELD> = LS_RETVAL-FIELDVAL.
  ENDIF.
  PERFORM 0224_CONDITION_VALUE_SET_DESC.
ENDFORM.
