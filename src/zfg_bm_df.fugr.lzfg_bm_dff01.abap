*----------------------------------------------------------------------*
***INCLUDE LZFG_BM_DFF01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  DF_STR_GET_CONFIG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_STRUCT  text
*----------------------------------------------------------------------*
FORM DF_STR_GET_CONFIG
  USING  LPW_TABNAME          TYPE TABNAME
         LPS_STRUCT
  CHANGING LPS_DF_STR         TYPE ZST_BM_DF_STR.
  DATA:
    LW_TABNAME                TYPE TABNAME,
    LS_DF_TYPE                TYPE ZTB_BM_DF_TYP,
    LS_DF_TYPLS               TYPE ZTB_BM_DF_TYPLS,
    LS_NEST_TYPLS             TYPE ZST_BM_DF_TYPLS.
  FIELD-SYMBOLS:
    <LF_NEST_FIELD>           TYPE ZST_BM_DF_FIELD.

  IF LPW_TABNAME IS INITIAL.
    DESCRIBE FIELD LPS_STRUCT HELP-ID LW_TABNAME.
  ELSE.
    LW_TABNAME = LPW_TABNAME.
  ENDIF.

* Get structure
  SELECT SINGLE *
    FROM ZTB_BM_DF_STR
    INTO CORRESPONDING FIELDS OF LPS_DF_STR
   WHERE TABNM = LW_TABNAME.

* Get fields format
  SELECT *
    FROM ZTB_BM_DF_FIELD
    INTO CORRESPONDING FIELDS OF TABLE LPS_DF_STR-FIELDS
   WHERE TABNM = LW_TABNAME
   ORDER BY FPOSI.

  IF GT_DF_TYPE IS INITIAL.
*   Get data format types
    SELECT *
      FROM ZTB_BM_DF_TYP
      INTO TABLE GT_DF_TYPE
     ORDER BY TYPEID.

*   Get data format type values list
    SELECT *
      FROM ZTB_BM_DF_TYPLS
      INTO TABLE GT_DF_TYPLS
     ORDER BY TYPEID.

*   Get data format type error code
    SELECT *
      FROM ZTB_BM_DF_TYP_EC
      INTO TABLE GT_DF_TYPEC
     ORDER BY TYPEID.

*   Get data error code
    SELECT *
      FROM ZTB_BM_DF_EC
      INTO TABLE GT_DF_ECODE.
  ENDIF.

* Aggregate format
  LOOP AT LPS_DF_STR-FIELDS ASSIGNING <LF_NEST_FIELD>.
    <LF_NEST_FIELD>-ELIST     = LPS_DF_STR-ELIST.
    <LF_NEST_FIELD>-IDFIELD   = LPS_DF_STR-IDFIELD.
    <LF_NEST_FIELD>-TABDS     = LPS_DF_STR-DESCR.

    READ TABLE GT_DF_TYPE INTO LS_DF_TYPE BINARY SEARCH
      WITH KEY TYPEID = <LF_NEST_FIELD>-TYPEID.
    IF SY-SUBRC IS INITIAL.
      MOVE-CORRESPONDING LS_DF_TYPE TO <LF_NEST_FIELD>.
      LOOP AT GT_DF_TYPLS INTO LS_DF_TYPLS
        WHERE TYPEID = LS_DF_TYPE-TYPEID.
        MOVE-CORRESPONDING LS_DF_TYPLS TO LS_NEST_TYPLS.
        APPEND LS_NEST_TYPLS TO <LF_NEST_FIELD>-TYPLS.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " DF_STR_GET_CONFIG

*&---------------------------------------------------------------------*
*&      Form  DF_STR_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_STRUCT  text
*      <--LPS_DF_STR  text
*      <--LPT_RETURN  text
*----------------------------------------------------------------------*
FORM DF_STR_CHECK
  USING    LPS_DF_STR         TYPE ZST_BM_DF_STR
  CHANGING LPS_STRUCT
           LPS_ROOTSTR
           LPT_RETURN         TYPE BAPIRET2_T
           LPT_FIELD_EC       TYPE ZTT_BM_DF_FIELD_EC.
  DATA:
    LS_DF_FIELD               TYPE ZST_BM_DF_FIELD,
    LS_RETURN                 TYPE BAPIRET2,
    LS_STRUCT_ID              TYPE GTY_STRUCT_ID.
  FIELD-SYMBOLS:
    <LF_FIELD_TAB>            TYPE ANY TABLE,
    <LF_FIELD_DET>            TYPE ANY,
    <LF_GUID>                 TYPE SYSUUID_C32,
    <LF_RECORDID>             TYPE ANY.

  CLEAR: LS_STRUCT_ID.

* Gen GUID
  IF LPS_DF_STR-GUIDFIELD IS NOT INITIAL.
    ASSIGN COMPONENT LPS_DF_STR-GUIDFIELD OF STRUCTURE LPS_STRUCT
      TO <LF_GUID>.
    IF SY-SUBRC IS INITIAL.
*     Create GUID
      CALL METHOD CL_SYSTEM_UUID=>IF_SYSTEM_UUID_STATIC~CREATE_UUID_C32
        RECEIVING
          UUID = <LF_GUID>.
      LS_STRUCT_ID-RECORDGUID = <LF_GUID>.
    ENDIF.
  ENDIF.

* Get record ID
  IF LPS_DF_STR-IDFIELD IS NOT INITIAL.
    ASSIGN COMPONENT LPS_DF_STR-IDFIELD OF STRUCTURE LPS_STRUCT
      TO <LF_RECORDID>.
    IF SY-SUBRC IS INITIAL.
      LS_STRUCT_ID-RECORDID = <LF_RECORDID>.
    ENDIF.
  ENDIF.

  LOOP AT LPS_DF_STR-FIELDS INTO LS_DF_FIELD.
    IF LS_DF_FIELD-ROWTYP IS INITIAL.
      PERFORM DF_FIELD_CHECK
        USING LS_DF_FIELD
              LS_STRUCT_ID
        CHANGING LPS_STRUCT
                 LPS_ROOTSTR
                 LPT_RETURN
                 LPT_FIELD_EC.
    ELSE.
      ASSIGN COMPONENT LS_DF_FIELD-FNAME OF STRUCTURE LPS_STRUCT
        TO <LF_FIELD_TAB>.
      IF SY-SUBRC IS INITIAL.
        LOOP AT <LF_FIELD_TAB> ASSIGNING <LF_FIELD_DET>.
          CALL FUNCTION 'ZFM_BM_DF_STR_CHECK'
            IMPORTING
              ET_RETURN   = LPT_RETURN
              ET_FIELD_EC = LPT_FIELD_EC
            CHANGING
              C_STRUCT    = <LF_FIELD_DET>
              C_ROOTSTR   = LPS_ROOTSTR.

        ENDLOOP.
*       Call enhance funtion
        IF LS_DF_FIELD-EHFUNC IS NOT INITIAL.
*          CALL FUNCTION 'ZFM_BM_DF_FCHK_TEMPL_EHFUNC'
          CALL FUNCTION LS_DF_FIELD-EHFUNC
            EXPORTING
              I_FIELD     = <LF_FIELD_TAB>
              I_DF_FIELD  = LS_DF_FIELD
              I_RECORD    = LPS_STRUCT
              I_ROOTSTR   = LPS_ROOTSTR
            IMPORTING
              ET_FIELD_EC = LPT_FIELD_EC.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " DF_STR_CHECK

*&---------------------------------------------------------------------*
*&      Form  DF_FIELD_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_DF_FIELD  text
*      <--LPS_STRUCT  text
*      <--LPS_RETURN  text
*----------------------------------------------------------------------*
FORM DF_FIELD_CHECK
  USING    LPS_DF_FIELD       TYPE ZST_BM_DF_FIELD
           LPS_STRUCT_ID      TYPE GTY_STRUCT_ID
  CHANGING LPS_STRUCT
           LPS_ROOTSTR
           LPT_RETURN         TYPE BAPIRET2_T
           LPT_FIELD_EC       TYPE ZTT_BM_DF_FIELD_EC.
  DATA:
    LS_RETURN                 TYPE BAPIRET2,
    LT_FIELD_EC               TYPE ZTT_BM_DF_FIELD_EC.
  FIELD-SYMBOLS:
    <LF_FIELD>                TYPE ANY.


* Get field value to check format
  ASSIGN COMPONENT LPS_DF_FIELD-FNAME OF STRUCTURE LPS_STRUCT
    TO <LF_FIELD>.
  CHECK SY-SUBRC IS INITIAL.

* Check required, length
  PERFORM DF_FIELD_CHECK_REQ_LEN
    USING <LF_FIELD>
          LPS_DF_FIELD
    CHANGING LS_RETURN
             LT_FIELD_EC.
* Put error to out parameters
  IF LS_RETURN IS NOT INITIAL.
    LS_RETURN-ROW = LPS_STRUCT_ID-RECORDID.
    APPEND LS_RETURN TO LPT_RETURN.

*   Return error fields
    PERFORM 9999_PUT_ERROR_CODE
      USING LPS_STRUCT_ID
            LT_FIELD_EC
      CHANGING LPT_FIELD_EC.
    RETURN.
  ENDIF.

  CASE LPS_DF_FIELD-CHKTYP.
*   Check by format
    WHEN GC_CHKTYP_FORMAT.
      PERFORM DF_FIELD_CHECK_FORMAT
        USING LPS_DF_FIELD
        CHANGING <LF_FIELD>
                 LS_RETURN
                 LT_FIELD_EC.

*   Check by function module
    WHEN GC_CHKTYP_FM.
*      CALL FUNCTION 'ZFM_BM_DF_FCHK_ADR_REGION'
      IF LPS_DF_FIELD-FUNCNAME  IS NOT INITIAL.
        CALL FUNCTION LPS_DF_FIELD-FUNCNAME
          EXPORTING
            I_FIELD     = <LF_FIELD>
            I_DF_FIELD  = LPS_DF_FIELD
            I_RECORD    = LPS_STRUCT
          IMPORTING
            E_FIELD     = <LF_FIELD>
            E_RETURN    = LS_RETURN
            ET_FIELD_EC = LT_FIELD_EC.
      ENDIF.

*   Check in list
    WHEN GC_CHKTYP_LIST.
*     Check in list
      PERFORM DF_FIELD_CHECK_LIST
        USING LPS_DF_FIELD
      CHANGING <LF_FIELD>
               LS_RETURN
               LT_FIELD_EC.
    WHEN OTHERS.
  ENDCASE.

* Put error to out parameters
  IF LS_RETURN IS NOT INITIAL.
    LS_RETURN-ROW = LPS_STRUCT_ID-RECORDID.
    APPEND LS_RETURN TO LPT_RETURN.
  ELSEIF LPS_DF_FIELD-EHFUNC IS NOT INITIAL.
*   Call enhance funtion
*    CALL FUNCTION 'ZFM_BM_DF_FCHK_TEMPL_EHFUNC'
    CALL FUNCTION LPS_DF_FIELD-EHFUNC
      EXPORTING
        I_FIELD     = <LF_FIELD>
        I_DF_FIELD  = LPS_DF_FIELD
        I_RECORD    = LPS_STRUCT
        I_ROOTSTR   = LPS_ROOTSTR
      IMPORTING
        ET_FIELD_EC = LT_FIELD_EC.
  ENDIF.

* Return error fields
  PERFORM 9999_PUT_ERROR_CODE
    USING LPS_STRUCT_ID
          LT_FIELD_EC
    CHANGING LPT_FIELD_EC.

ENDFORM.                    " DF_FIELD_CHECK

*&---------------------------------------------------------------------*
*&      Form  DF_FIELD_CHECK_FORMAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_FIELD  text
*      -->LPW_CFORMAT  text
*      <--LPS_RETURN  text
*----------------------------------------------------------------------*
FORM DF_FIELD_CHECK_FORMAT
  USING    LPS_DF_FIELD       TYPE ZST_BM_DF_FIELD
  CHANGING LPW_FIELD
           LPS_RETURN         TYPE BAPIRET2
           LPT_FIELD_EC       TYPE ZTT_BM_DF_FIELD_EC.
  DATA:
    LS_RETURN                 TYPE BAPIRET2.
  FIELD-SYMBOLS:
    <LF_FIELD>                TYPE ANY.

  CLEAR: LPS_RETURN.

  CHECK LPW_FIELD IS NOT INITIAL.

  CASE LPS_DF_FIELD-CFORMAT.
*   dd-mm-yyyy
    WHEN GC_CFORMAT_D1.
      PERFORM DF_FIELD_CHECK_FORMAT_DATE
        USING LPS_DF_FIELD
              GC_REGEX_D1
              GC_REGEX_REPLACE_D1
              GC_TFORMAT_D1
        CHANGING LPW_FIELD
                 LPS_RETURN
                 LPT_FIELD_EC.
*   dd/mm/yyyy
    WHEN GC_CFORMAT_D2.
      PERFORM DF_FIELD_CHECK_FORMAT_DATE
        USING LPS_DF_FIELD
              GC_REGEX_D2
              GC_REGEX_REPLACE_D2
              GC_TFORMAT_D2
        CHANGING LPW_FIELD
                 LPS_RETURN
                 LPT_FIELD_EC.
*   yyyy-mm-dd
    WHEN GC_CFORMAT_D3.
      PERFORM DF_FIELD_CHECK_FORMAT_DATE
        USING LPS_DF_FIELD
              GC_REGEX_D3
              GC_REGEX_REPLACE_D3
              GC_TFORMAT_D3
        CHANGING LPW_FIELD
                 LPS_RETURN
                 LPT_FIELD_EC.
*   dd-mmm-yyyy hh:mm:ss
    WHEN GC_CFORMAT_D4.
      PERFORM DF_FIELD_CHECK_FORMAT_DATE
        USING LPS_DF_FIELD
              GC_REGEX_D4
              GC_REGEX_REPLACE_D4
              GC_TFORMAT_D4
        CHANGING LPW_FIELD
                 LPS_RETURN
                 LPT_FIELD_EC.
*   dd.mm.yyyy
    WHEN GC_CFORMAT_D5.
      PERFORM DF_FIELD_CHECK_FORMAT_DATE
        USING LPS_DF_FIELD
              GC_REGEX_D5
              GC_REGEX_REPLACE_D5
              GC_TFORMAT_D5
        CHANGING LPW_FIELD
                 LPS_RETURN
                 LPT_FIELD_EC.
*   mm-yyyy
    WHEN GC_CFORMAT_M1.
      PERFORM DF_FIELD_CHECK_FORMAT_REGEX
        USING LPS_DF_FIELD
              GC_REGEX_M1
              GC_REGEX_REPLACE_M1
              GC_TFORMAT_M1
        CHANGING LPW_FIELD
                 LPS_RETURN
                 LPT_FIELD_EC.
*   Currency
    WHEN GC_CFORMAT_CUR.
      PERFORM DF_FIELD_CHECK_FORMAT_REGEX
        USING LPS_DF_FIELD
              GC_REGEX_CUR
              GC_REGEX_REPLACE_CUR
              GC_TFORMAT_CUR
        CHANGING LPW_FIELD
                 LPS_RETURN
                 LPT_FIELD_EC.
*   Number
    WHEN GC_CFORMAT_NUM.
      PERFORM DF_FIELD_CHECK_FORMAT_REGEX
        USING LPS_DF_FIELD
              GC_REGEX_NUM
              GC_REGEX_REPLACE_NUM
              GC_TFORMAT_NUM
        CHANGING LPW_FIELD
                 LPS_RETURN
                 LPT_FIELD_EC.
*   Decimal
    WHEN GC_CFORMAT_DEC.
      PERFORM DF_FIELD_CHECK_FORMAT_REGEX
        USING LPS_DF_FIELD
              GC_REGEX_DEC
              GC_REGEX_REPLACE_DEC
              GC_TFORMAT_DEC
        CHANGING LPW_FIELD
                 LPS_RETURN
                 LPT_FIELD_EC.
*   Char
    WHEN GC_CFORMAT_CHR.
    WHEN OTHERS.
  ENDCASE.

  CALL FUNCTION 'ZFM_BM_DF_FCHK_GRP_PUT'
    EXPORTING
      I_FIELD     = LPW_FIELD
      I_DF_FIELD  = LPS_DF_FIELD
      I_FIELDCODE = LPS_DF_FIELD-TYPEID.

ENDFORM.                    " DF_FIELD_CHECK_FORMAT

*&---------------------------------------------------------------------*
*&      Form  DF_FIELD_CHECK_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_FIELD  text
*      -->LPS_DF_FIELD  text
*      <--LPS_RETURN  text
*----------------------------------------------------------------------*
FORM DF_FIELD_CHECK_LIST
  USING    LPS_DF_FIELD       TYPE ZST_BM_DF_FIELD
  CHANGING LPW_FIELD
           LPS_RETURN         TYPE BAPIRET2
           LPT_FIELD_EC       TYPE ZTT_BM_DF_FIELD_EC.
  DATA:
    LS_DF_TYPLS               TYPE ZST_BM_DF_TYPLS,
    LS_RETURN                 TYPE BAPIRET2,
    LS_FIELD_EC               TYPE ZST_BM_DF_FIELD_EC,
    LS_DF_TYPEC               TYPE ZTB_BM_DF_TYP_EC,
    LS_DF_ECODE               TYPE ZTB_BM_DF_EC.

  CLEAR: LPS_RETURN.

  READ TABLE LPS_DF_FIELD-TYPLS INTO LS_DF_TYPLS
    WITH KEY VALUE = LPW_FIELD.
  IF SY-SUBRC IS INITIAL.
    IF LS_DF_TYPLS-OUTVAL IS NOT INITIAL.
      IF LS_DF_TYPLS-OUTVAL = '#'.
        CLEAR: LPW_FIELD.
      ELSE.
        LPW_FIELD = LS_DF_TYPLS-OUTVAL.
      ENDIF.
    ENDIF.
  ELSE.
    LPS_RETURN-ID             = 'ZMS_COL_LIB'.
    LPS_RETURN-TYPE           = GC_MTYPE_E.
    LPS_RETURN-NUMBER         = '022'.
    IF LPS_DF_FIELD-DESCR IS INITIAL.
      PERFORM 9999_SPLIT_GET_SINGLE_FIELD
        USING LPS_DF_FIELD-FNAME
        CHANGING LPS_RETURN-FIELD.
      LPS_RETURN-MESSAGE_V1     = LPS_RETURN-FIELD.
    ELSE.
      LPS_RETURN-MESSAGE_V1     = LPS_DF_FIELD-DESCR.
    ENDIF.
    LPS_RETURN-MESSAGE_V2     = LPW_FIELD.
    MESSAGE E022(ZMS_COL_LIB) INTO LPS_RETURN-MESSAGE
      WITH LPS_RETURN-MESSAGE_V1 LPS_RETURN-MESSAGE_V2
           LPS_RETURN-MESSAGE_V3 LPS_RETURN-MESSAGE_V4.

*   Get error code
    CALL FUNCTION 'ZFM_BM_DF_MAP_ERRCODE'
      EXPORTING
        I_DF_FIELD  = LPS_DF_FIELD
        I_RETURN    = LPS_RETURN
        I_EVLDB     = GC_XMARK
      IMPORTING
        ET_FIELD_EC = LPT_FIELD_EC.
  ENDIF.

  CALL FUNCTION 'ZFM_BM_DF_FCHK_GRP_PUT'
    EXPORTING
      I_FIELD     = LPW_FIELD
      I_DF_FIELD  = LPS_DF_FIELD
      I_FIELDCODE = LPS_DF_FIELD-TYPEID.

ENDFORM.                    " DF_FIELD_CHECK_LIST

*&---------------------------------------------------------------------*
*&      Form  DF_FIELD_CHECK_FORMAT_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_FIELD  text
*      -->LPS_DF_FIELD  text
*      -->LPW_REGEX  text
*      -->LPW_REGEX_REPLACE  text
*      -->LPW_TFORMAT  text
*      <--LPS_RETURN  text
*----------------------------------------------------------------------*
FORM DF_FIELD_CHECK_FORMAT_DATE
  USING    LPS_DF_FIELD       TYPE ZST_BM_DF_FIELD
           LPW_REGEX          TYPE STRING
           LPW_REGEX_REPLACE  TYPE STRING
           LPW_TFORMAT
  CHANGING LPW_FIELD
           LPS_RETURN         TYPE BAPIRET2
           LPT_FIELD_EC       TYPE ZTT_BM_DF_FIELD_EC.
  DATA:
    LW_VALUE                  TYPE STRING,
    LW_DATE                   TYPE DATUM.

* Check regular expression
  LW_VALUE = LPW_FIELD.
  PERFORM DF_FIELD_CHECK_FORMAT_REGEX
    USING LPS_DF_FIELD
          LPW_REGEX
          LPW_REGEX_REPLACE
          LPW_TFORMAT
    CHANGING LW_VALUE
             LPS_RETURN
             LPT_FIELD_EC.
  CHECK LPS_RETURN IS INITIAL.

* Convert if date is short date
  IF LW_VALUE CS '.'.
    TRANSLATE LW_VALUE TO UPPER CASE.
    CALL FUNCTION 'CONVERSION_EXIT_SDATE_INPUT'
      EXPORTING
        INPUT  = LW_VALUE
      IMPORTING
        OUTPUT = LW_DATE.
  ELSE.
    LW_DATE = LW_VALUE.
  ENDIF.

* Check date valid
  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      DATE                      = LW_DATE
    EXCEPTIONS
      PLAUSIBILITY_CHECK_FAILED = 1
      OTHERS                    = 2.
  IF SY-SUBRC <> 0.
    PERFORM DF_FIELD_SET_ERR_FORMAT
      USING LPW_FIELD
            LPS_DF_FIELD
            LPW_TFORMAT
      CHANGING LPS_RETURN
               LPT_FIELD_EC.
    RETURN.
    CLEAR: LPW_FIELD.
  ELSE.
    LPW_FIELD = LW_DATE.
  ENDIF.
ENDFORM.                    " DF_FIELD_CHECK_FORMAT_DATE
*&---------------------------------------------------------------------*
*&      Form  DF_FIELD_SET_ERR_FORMAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_FIELD  text
*      -->LPS_DF_FIELD  text
*      -->LPW_TFORMAT  text
*      <--LPS_RETURN  text
*----------------------------------------------------------------------*
FORM DF_FIELD_SET_ERR_FORMAT
  USING    LPW_FIELD
           LPS_DF_FIELD       TYPE ZST_BM_DF_FIELD
           LPW_TFORMAT
  CHANGING LPS_RETURN         TYPE BAPIRET2
           LPT_FIELD_EC       TYPE ZTT_BM_DF_FIELD_EC.
  DATA:
    LS_FIELD_EC               TYPE ZST_BM_DF_FIELD_EC,
    LS_DF_TYPEC               TYPE ZTB_BM_DF_TYP_EC,
    LS_DF_ECODE               TYPE ZTB_BM_DF_EC.

  LPS_RETURN-ID               = 'ZMS_COL_LIB'.
  LPS_RETURN-TYPE             = GC_MTYPE_E.
  LPS_RETURN-NUMBER           = '021'.
  IF LPS_DF_FIELD-DESCR IS INITIAL.
    PERFORM 9999_SPLIT_GET_SINGLE_FIELD
      USING LPS_DF_FIELD-FNAME
      CHANGING LPS_RETURN-FIELD.
    LPS_RETURN-MESSAGE_V1     = LPS_RETURN-FIELD.
  ELSE.
    LPS_RETURN-MESSAGE_V1     = LPS_DF_FIELD-DESCR.
  ENDIF.
  LPS_RETURN-MESSAGE_V2       = LPW_FIELD.
  LPS_RETURN-MESSAGE_V3       = LPW_TFORMAT.
  MESSAGE E021(ZMS_COL_LIB)
    WITH LPS_RETURN-MESSAGE_V1 LPS_RETURN-MESSAGE_V2
         LPS_RETURN-MESSAGE_V3
    INTO LPS_RETURN-MESSAGE.

* Get error code
  CALL FUNCTION 'ZFM_BM_DF_MAP_ERRCODE'
    EXPORTING
      I_DF_FIELD  = LPS_DF_FIELD
      I_RETURN    = LPS_RETURN
      I_EFMAT     = GC_XMARK
    IMPORTING
      ET_FIELD_EC = LPT_FIELD_EC.

ENDFORM.                    " DF_FIELD_SET_ERR_FORMAT

*&---------------------------------------------------------------------*
*&      Form  DF_FIELD_CHECK_FORMAT_REGEX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_FIELD  text
*      -->LPS_DF_FIELD  text
*      -->LPW_REGEX  text
*      -->LPW_REGEX_REPLACE  text
*      -->LPW_TFORMAT  text
*      <--LPS_RETURN  text
*----------------------------------------------------------------------*
FORM DF_FIELD_CHECK_FORMAT_REGEX
  USING    LPS_DF_FIELD       TYPE ZST_BM_DF_FIELD
           LPW_REGEX          TYPE STRING
           LPW_REGEX_REPLACE  TYPE STRING
           LPW_TFORMAT
  CHANGING LPW_VALUE
           LPS_RETURN         TYPE BAPIRET2
           LPT_FIELD_EC       TYPE ZTT_BM_DF_FIELD_EC.

  REPLACE FIRST OCCURRENCE OF REGEX LPW_REGEX
    IN LPW_VALUE WITH LPW_REGEX_REPLACE.
  IF SY-SUBRC IS NOT INITIAL.
    PERFORM DF_FIELD_SET_ERR_FORMAT
      USING LPW_VALUE
            LPS_DF_FIELD
            LPW_TFORMAT
      CHANGING LPS_RETURN
               LPT_FIELD_EC.
    CLEAR: LPW_VALUE.
  ENDIF.

ENDFORM.                    " DF_FIELD_CHECK_FORMAT_REGEX
*&---------------------------------------------------------------------*
*&      Form  DF_FIELD_CHECK_REQ_LEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_FIELD  text
*      -->LPS_DF_FIELD  text
*      <--LPS_RETURN  text
*----------------------------------------------------------------------*
FORM DF_FIELD_CHECK_REQ_LEN
  USING    LPW_FIELD
           LPS_DF_FIELD       TYPE ZST_BM_DF_FIELD
  CHANGING LPS_RETURN         TYPE BAPIRET2
           LPT_FIELD_EC       TYPE ZTT_BM_DF_FIELD_EC.

  DATA:
    LS_FIELD_EC               TYPE ZST_BM_DF_FIELD_EC,
    LS_DF_TYPEC               TYPE ZTB_BM_DF_TYP_EC,
    LS_DF_ECODE               TYPE ZTB_BM_DF_EC.

  IF LPS_DF_FIELD-CHKINIT IS NOT INITIAL
  AND LPW_FIELD IS INITIAL.
    PERFORM DF_FIELD_SET_ERR_INIT
      USING LPW_FIELD
            LPS_DF_FIELD
      CHANGING LPS_RETURN
               LPT_FIELD_EC.
  ENDIF.

  IF LPS_DF_FIELD-LENGTH IS NOT INITIAL
  AND STRLEN( LPW_FIELD ) > LPS_DF_FIELD-LENGTH.
    LPS_RETURN-ID             = 'ZMS_COL_LIB'.
    LPS_RETURN-TYPE           = GC_MTYPE_E.
    LPS_RETURN-NUMBER         = '020'.
    IF LPS_DF_FIELD-DESCR IS INITIAL.
      PERFORM 9999_SPLIT_GET_SINGLE_FIELD
        USING LPS_DF_FIELD-FNAME
        CHANGING LPS_RETURN-FIELD.
      LPS_RETURN-MESSAGE_V1     = LPS_RETURN-FIELD.
    ELSE.
      LPS_RETURN-MESSAGE_V1     = LPS_DF_FIELD-DESCR.
    ENDIF.
    LPS_RETURN-MESSAGE_V2     = LPW_FIELD.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LPS_DF_FIELD-LENGTH
      IMPORTING
        OUTPUT = LPS_RETURN-MESSAGE_V3.
    MESSAGE E020(ZMS_COL_LIB)
      WITH LPS_RETURN-MESSAGE_V1 LPS_RETURN-MESSAGE_V2
           LPS_RETURN-MESSAGE_V3
      INTO LPS_RETURN-MESSAGE.

*   Get error code
    CALL FUNCTION 'ZFM_BM_DF_MAP_ERRCODE'
      EXPORTING
        I_DF_FIELD  = LPS_DF_FIELD
        I_RETURN    = LPS_RETURN
        I_ELENG     = GC_XMARK
      IMPORTING
        ET_FIELD_EC = LPT_FIELD_EC.
  ENDIF.

ENDFORM.                    " DF_FIELD_CHECK_REQ_LEN
*&---------------------------------------------------------------------*
*&      Form  DF_FIELD_SET_ERR_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_FIELD  text
*      -->LPS_DF_FIELD  text
*      -->LPW_TFORMAT  text
*      <--LPS_RETURN  text
*----------------------------------------------------------------------*
FORM DF_FIELD_SET_ERR_INIT
  USING    LPW_FIELD
           LPS_DF_FIELD       TYPE ZST_BM_DF_FIELD
  CHANGING LPS_RETURN         TYPE BAPIRET2
           LPT_FIELD_EC       TYPE ZTT_BM_DF_FIELD_EC.
  DATA:
    LS_FIELD_EC               TYPE ZST_BM_DF_FIELD_EC,
    LS_DF_TYPEC               TYPE ZTB_BM_DF_TYP_EC,
    LS_DF_ECODE               TYPE ZTB_BM_DF_EC.

  LPS_RETURN-ID               = 'ZMS_COL_LIB'.
  LPS_RETURN-TYPE             = GC_MTYPE_E.
  LPS_RETURN-NUMBER           = '001'.
  IF LPS_DF_FIELD-DESCR IS INITIAL.
    PERFORM 9999_SPLIT_GET_SINGLE_FIELD
      USING LPS_DF_FIELD-FNAME
      CHANGING LPS_RETURN-FIELD.
    LPS_RETURN-MESSAGE_V1     = LPS_RETURN-FIELD.
  ELSE.
    LPS_RETURN-MESSAGE_V1     = LPS_DF_FIELD-DESCR.
  ENDIF.
  LPS_RETURN-MESSAGE_V2       = LPS_DF_FIELD-TABDS.
  MESSAGE E001(ZMS_COL_LIB) WITH LPS_RETURN-MESSAGE_V1
    INTO LPS_RETURN-MESSAGE.

* Get error code
  CALL FUNCTION 'ZFM_BM_DF_MAP_ERRCODE'
    EXPORTING
      I_DF_FIELD  = LPS_DF_FIELD
      I_RETURN    = LPS_RETURN
      I_EINIT     = GC_XMARK
    IMPORTING
      ET_FIELD_EC = LPT_FIELD_EC.

ENDFORM.                    " DF_FIELD_SET_ERR_INIT

*&---------------------------------------------------------------------*
*&      Form  9999_INIT_ADR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 9999_INIT_ADR .
  IF GT_COUNTRY IS INITIAL.
    SELECT *
      FROM T005
      INTO TABLE GT_COUNTRY.
  ENDIF.
  SORT GT_COUNTRY BY LAND1.

  IF GT_REGIONS IS INITIAL.
    SELECT S~LAND1 S~BLAND BEZEI
      INTO TABLE GT_REGIONS
      FROM T005S AS S LEFT JOIN T005U AS U
        ON S~LAND1 = U~LAND1 AND S~BLAND = U~BLAND
       AND U~SPRAS = SY-LANGU.
  ENDIF.

  IF GT_CITY IS INITIAL.
    SELECT C~COUNTRY C~REGION C~CITY_CODE CITY_NAME CITY_SHORT
      INTO TABLE GT_CITY
      FROM ADRCITY AS C LEFT JOIN ADRCITYT AS T
        ON C~COUNTRY = T~COUNTRY AND C~CITY_CODE = T~CITY_CODE
       AND T~LANGU = SY-LANGU.
    SORT GT_CITY BY COUNTRY REGION CITY_CODE.
  ENDIF.

  IF GT_DISTRICT IS INITIAL.
    SELECT COUNTRY CITY_CODE CITYP_CODE CITY_PART
      INTO TABLE GT_DISTRICT
      FROM ADRCITYPRT.
    SORT GT_DISTRICT BY COUNTRY CITY_CODE CITYP_CODE.
  ENDIF.

ENDFORM.                    " 9999_INIT_ADR

*&---------------------------------------------------------------------*
*&      Form  9999_SPLIT_GET_SINGLE_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_SCRFNAME  text
*      <--LPW_FNAME  text
*----------------------------------------------------------------------*
FORM 9999_SPLIT_GET_SINGLE_FIELD
  USING    LPW_SCRFNAME       TYPE SCRFNAME
  CHANGING LPW_FNAME          TYPE FIELDNAME.
  DATA:
    LT_FIELDNAME              TYPE FIELDNAME_TAB.

  IF LPW_SCRFNAME CS '-'.
    SPLIT LPW_SCRFNAME AT '-' INTO TABLE LT_FIELDNAME.
    READ TABLE LT_FIELDNAME INTO LPW_FNAME INDEX LINES( LT_FIELDNAME ).
  ELSE.
    LPW_FNAME                 = LPW_SCRFNAME.
  ENDIF.
ENDFORM.                    " 9999_SPLIT_GET_SINGLE_FIELD

*&---------------------------------------------------------------------*
*&      Form  DF_CITY_SET_ERR_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_FIELD  text
*      -->LPS_DF_FIELD  text
*      <--LPS_RETURN  text
*----------------------------------------------------------------------*
FORM DF_CITY_SET_ERR_DB
  USING    LPW_FIELD
           LPS_DF_FIELD       TYPE ZST_BM_DF_FIELD
  CHANGING LPS_RETURN         TYPE BAPIRET2
           LPT_FIELD_EC       TYPE ZTT_BM_DF_FIELD_EC.
  DATA:
    LS_FIELD_EC               TYPE ZST_BM_DF_FIELD_EC,
    LS_DF_TYPEC               TYPE ZTB_BM_DF_TYP_EC,
    LS_DF_ECODE               TYPE ZTB_BM_DF_EC.

  LPS_RETURN-ID               = 'ZMS_COL_LIB'.
  LPS_RETURN-TYPE             = GC_MTYPE_E.
  LPS_RETURN-NUMBER           = '027'.
  PERFORM 9999_SPLIT_GET_SINGLE_FIELD
    USING LPS_DF_FIELD-FNAME
    CHANGING LPS_RETURN-FIELD.
  LPS_RETURN-MESSAGE_V1       = LPS_RETURN-FIELD.
  LPS_RETURN-MESSAGE_V2       = LPW_FIELD.
  MESSAGE E027(ZMS_COL_LIB)
    WITH LPS_RETURN-MESSAGE_V1 LPS_RETURN-MESSAGE_V2
    INTO LPS_RETURN-MESSAGE.

* Get error code
  CALL FUNCTION 'ZFM_BM_DF_MAP_ERRCODE'
    EXPORTING
      I_DF_FIELD  = LPS_DF_FIELD
      I_RETURN    = LPS_RETURN
    IMPORTING
      ET_FIELD_EC = LPT_FIELD_EC.

ENDFORM.                    " DF_CITY_SET_ERR_DB

*&---------------------------------------------------------------------*
*&      Form  DF_DISTRICT_SET_ERR_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_FIELD  text
*      -->LPS_DF_FIELD  text
*      <--LPS_RETURN  text
*----------------------------------------------------------------------*
FORM DF_DISTRICT_SET_ERR_DB
  USING    LPW_FIELD
           LPS_DF_FIELD       TYPE ZST_BM_DF_FIELD
  CHANGING LPS_RETURN         TYPE BAPIRET2
           LPT_FIELD_EC       TYPE ZTT_BM_DF_FIELD_EC.
  DATA:
    LS_FIELD_EC               TYPE ZST_BM_DF_FIELD_EC,
    LS_DF_TYPEC               TYPE ZTB_BM_DF_TYP_EC,
    LS_DF_ECODE               TYPE ZTB_BM_DF_EC.

  LPS_RETURN-ID               = 'ZMS_COL_LIB'.
  LPS_RETURN-TYPE             = GC_MTYPE_E.
  LPS_RETURN-NUMBER           = '026'.
  PERFORM 9999_SPLIT_GET_SINGLE_FIELD
    USING LPS_DF_FIELD-FNAME
    CHANGING LPS_RETURN-FIELD.
  LPS_RETURN-MESSAGE_V1       = LPS_RETURN-FIELD.
  LPS_RETURN-MESSAGE_V2       = LPW_FIELD.
  MESSAGE E026(ZMS_COL_LIB)
    WITH LPS_RETURN-MESSAGE_V1 LPS_RETURN-MESSAGE_V2
    INTO LPS_RETURN-MESSAGE.

* Get error code
  CALL FUNCTION 'ZFM_BM_DF_MAP_ERRCODE'
    EXPORTING
      I_DF_FIELD  = LPS_DF_FIELD
      I_RETURN    = LPS_RETURN
    IMPORTING
      ET_FIELD_EC = LPT_FIELD_EC.

ENDFORM.                    " DF_DISTRICT_SET_ERR_DB

*&---------------------------------------------------------------------*
*&      Form  DF_FIELD_SET_ERR_VALIDATE_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_FIELD  text
*      -->LPS_DF_FIELD  text
*      <--LPS_RETURN  text
*----------------------------------------------------------------------*
FORM DF_FIELD_SET_ERR_VALIDATE_DB
  USING    LPW_FIELD
           LPS_DF_FIELD       TYPE ZST_BM_DF_FIELD
  CHANGING LPS_RETURN         TYPE BAPIRET2
           LPT_FIELD_EC       TYPE ZTT_BM_DF_FIELD_EC.
  DATA:
    LS_FIELD_EC               TYPE ZST_BM_DF_FIELD_EC,
    LS_DF_TYPEC               TYPE ZTB_BM_DF_TYP_EC,
    LS_DF_ECODE               TYPE ZTB_BM_DF_EC.

  LPS_RETURN-ID               = 'ZMS_COL_LIB'.
  LPS_RETURN-TYPE             = GC_MTYPE_E.
  LPS_RETURN-NUMBER           = '022'.
  PERFORM 9999_SPLIT_GET_SINGLE_FIELD
    USING LPS_DF_FIELD-FNAME
    CHANGING LPS_RETURN-FIELD.
  LPS_RETURN-MESSAGE_V1       = LPS_RETURN-FIELD.
  LPS_RETURN-MESSAGE_V2       = LPW_FIELD.
  MESSAGE E022(ZMS_COL_LIB)
    WITH LPS_RETURN-MESSAGE_V1 LPS_RETURN-MESSAGE_V2
    INTO LPS_RETURN-MESSAGE.

* Get error code
  CALL FUNCTION 'ZFM_BM_DF_MAP_ERRCODE'
    EXPORTING
      I_DF_FIELD  = LPS_DF_FIELD
      I_RETURN    = LPS_RETURN
      I_EVLDB     = GC_XMARK
    IMPORTING
      ET_FIELD_EC = LPT_FIELD_EC.

ENDFORM.                    " DF_FIELD_SET_ERR_VALIDATE_DB

*&---------------------------------------------------------------------*
*&      Form  DF_FIELD_SET_ERR_VALIDATE_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_FIELD  text
*      -->LPS_DF_FIELD  text
*      <--LPS_RETURN  text
*----------------------------------------------------------------------*
FORM DF_FIELD_SET_ERR_GROUP_SAME
  USING    LPW_FIELD
           LPS_DF_FIELD       TYPE ZST_BM_DF_FIELD
  CHANGING LPS_RETURN         TYPE BAPIRET2.

  LPS_RETURN-ID               = 'ZMS_COL_LIB'.
  LPS_RETURN-TYPE             = GC_MTYPE_E.
  LPS_RETURN-NUMBER           = '023'.
  LPS_RETURN-FIELD            = LPS_DF_FIELD-CHKGRP.
  LPS_RETURN-MESSAGE_V1       = LPS_RETURN-FIELD.
  MESSAGE E023(ZMS_COL_LIB)
    WITH LPS_RETURN-MESSAGE_V1 LPS_RETURN-MESSAGE_V2
    INTO LPS_RETURN-MESSAGE.

ENDFORM.                    " DF_FIELD_SET_ERR_VALIDATE_DB

*&---------------------------------------------------------------------*
*&      Form  9999_PUT_ERROR_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_RECORDID  text
*      -->LPT_FIELD_EC_CUR  text
*      <--LPT_FIELD_EC_ALL  text
*----------------------------------------------------------------------*
FORM 9999_PUT_ERROR_CODE
  USING    LPS_STRUCT_ID      TYPE GTY_STRUCT_ID
           LPT_FIELD_EC_CUR   TYPE ZTT_BM_DF_FIELD_EC
  CHANGING LPT_FIELD_EC_ALL   TYPE ZTT_BM_DF_FIELD_EC.
  DATA:
    LS_FIELD_EC               TYPE ZST_BM_DF_FIELD_EC.

  IF LPS_STRUCT_ID IS INITIAL.
    APPEND LINES OF LPT_FIELD_EC_CUR TO LPT_FIELD_EC_ALL.
  ELSE.
    LOOP AT LPT_FIELD_EC_CUR INTO LS_FIELD_EC.
      LS_FIELD_EC-RECORDID    = LPS_STRUCT_ID-RECORDID.
      LS_FIELD_EC-RECORDGUID  = LPS_STRUCT_ID-RECORDGUID.
      APPEND LS_FIELD_EC TO LPT_FIELD_EC_ALL.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " 9999_PUT_ERROR_CODE
