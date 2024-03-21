FUNCTION ZFM_SCR_CHECK_VALUE_DB.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_CPROG) TYPE  CPROG DEFAULT SY-CPROG
*"     REFERENCE(I_DYNNR) TYPE  DYNNR DEFAULT SY-DYNNR
*"     REFERENCE(T_FIELD) TYPE  ZTT_FIELD_DB OPTIONAL
*"     REFERENCE(I_CSTEP) TYPE  ZDD_CHECK_STEP OPTIONAL
*"     REFERENCE(I_AUTO_STOP) TYPE  XMARK DEFAULT 'X'
*"  EXPORTING
*"     REFERENCE(T_ERR_FIELD) TYPE  ZTT_ERR_FIELD
*"--------------------------------------------------------------------
DATA:
    LS_FIELD      TYPE ZTB_FIELD_DB,    "Field info need check value
    LT_FIELD      TYPE ZTT_FIELD_DB,    "List of field info  to check
    LW_PG_FIELD   TYPE CHAR100,         "Program field: ([PgName])FName
    LW_ERR        TYPE XMARK,           "Error flag
    LW_CTABNM     TYPE CHAR100,         "Local check table name
    LW_TABNM      TYPE TABNM,           "Table name
    LW_FNAME      TYPE FIELDNAME,       "Field name
    LW_LFNAME     TYPE DFIES-LFIELDNAME,"Field with Long name
    LS_DFIES      TYPE DFIES,           "Description of field
    LW_WHERE      TYPE STRING,          "Where clause
    LS_ERR_FIELD  TYPE ZST_ERR_FIELD,   "Error field
    LW_SCRTEXT_L  TYPE SCRTEXT_L        "Field label
    .
  FIELD-SYMBOLS:
    <LF_CTAB>     TYPE ANY TABLE,       "Local check table
    <LF_RECORD>   TYPE ANY,             "Record of field if exist
    <LF_FIELD>    TYPE ANY,             "Field value
    <LF_KEYF1>    TYPE ANY,             "Key field 1
    <LF_KEYF2>    TYPE ANY,             "Key field 2
    <LF_KEYF3>    TYPE ANY,             "Key field 3
    <LF_TTARGET>  TYPE ANY.             "Text target in call program

* Init
  CLEAR: GT_ERR_FIELD[], T_ERR_FIELD.

* Get field list to process
  LT_FIELD = T_FIELD.
  DELETE LT_FIELD WHERE REPID <> I_CPROG OR DYNNR <> I_DYNNR.

* Delete field which not need to be check in this checking step
  IF I_CSTEP IS NOT INITIAL.
    DELETE LT_FIELD WHERE CSTEP <> I_CSTEP.
  ENDIF.

* Process field on screen
  LOOP AT LT_FIELD INTO LS_FIELD
    WHERE REPID = I_CPROG AND DYNNR = I_DYNNR.
*   Init
    CLEAR: LS_ERR_FIELD.

*   Get field reference in called program
    CONCATENATE '(' LS_FIELD-REPID ')'
                LS_FIELD-FIELDNAME
           INTO LW_PG_FIELD.
    ASSIGN (LW_PG_FIELD) TO <LF_FIELD>.

*   Check value of field is valid (exists in table data)
    IF SY-SUBRC IS INITIAL
    AND <LF_FIELD> IS NOT INITIAL
    AND LS_FIELD-TABNAME IS NOT INITIAL.
*     Get component name of check field
      IF LS_FIELD-KEYF1 IS NOT INITIAL.
        LW_FNAME = LS_FIELD-KEYF1.
      ELSE.
*       Get field type name
        DESCRIBE FIELD <LF_FIELD> HELP-ID LW_FNAME.

*       Get component name in structure
        IF LW_FNAME CS '-'.
          SPLIT LW_FNAME AT '-' INTO LW_FNAME LW_FNAME.
        ENDIF.
      ENDIF.
*--------------------------------------------------------------------*
*     Get parents value in called program
      IF LS_FIELD-PRFIELD2 IS NOT INITIAL.
*       Get Parents field value in called program
        CONCATENATE '(' I_CPROG ')' LS_FIELD-PRFIELD2 INTO LW_PG_FIELD.
        ASSIGN (LW_PG_FIELD) TO <LF_KEYF2>.
      ENDIF.
      IF LS_FIELD-PRFIELD3 IS NOT INITIAL.
*       Get Parents field value in called program
        CONCATENATE '(' I_CPROG ')' LS_FIELD-PRFIELD3 INTO LW_PG_FIELD.
        ASSIGN (LW_PG_FIELD) TO <LF_KEYF3>.
      ENDIF.

*     Check using: Local check table in called program
      CONCATENATE '(' I_CPROG ')' LS_FIELD-TABNAME INTO LW_CTABNM.
      ASSIGN (LW_CTABNM) TO <LF_CTAB>.
      IF SY-SUBRC IS INITIAL.
        IF  <LF_KEYF2> IS ASSIGNED AND <LF_KEYF2> IS NOT INITIAL
        AND <LF_KEYF3> IS ASSIGNED AND <LF_KEYF3> IS NOT INITIAL.
*         Search data from local check table
          READ TABLE <LF_CTAB> ASSIGNING <LF_RECORD>
            WITH KEY (LW_FNAME)       = <LF_FIELD>
                     (LS_FIELD-KEYF2) = <LF_KEYF2>
                     (LS_FIELD-KEYF3) = <LF_KEYF3>.
        ELSEIF <LF_KEYF2> IS ASSIGNED AND <LF_KEYF2> IS NOT INITIAL.
*         Search data from local check table
          READ TABLE <LF_CTAB> ASSIGNING <LF_RECORD>
            WITH KEY (LW_FNAME)       = <LF_FIELD>
                     (LS_FIELD-KEYF2) = <LF_KEYF2>.
        ELSE.
*         Search data from local check table
          READ TABLE <LF_CTAB> ASSIGNING <LF_RECORD>
            WITH KEY (LW_FNAME) = <LF_FIELD>.
        ENDIF.

*       Set description
        IF SY-SUBRC IS INITIAL
        AND LS_FIELD-TEXT_FIELD IS NOT INITIAL
        AND LS_FIELD-TEXT_TARGET IS NOT INITIAL.
          PERFORM SET_DESC_VALUE USING LS_FIELD <LF_RECORD>.
        ENDIF.
*--------------------------------------------------------------------*
*     Check using: DB table
      ELSE.
*       Build where clause: [Fieldname] = [Fieldvalue]
        CONCATENATE LW_FNAME ' = ''' <LF_FIELD> '''' INTO LW_WHERE.
*       Build where clause: [KeyF2] = [KeyF2Value]
        IF <LF_KEYF2> IS ASSIGNED AND <LF_KEYF2> IS NOT INITIAL.
          CONCATENATE LW_WHERE ' AND '
                      LS_FIELD-KEYF2 ' = ''' <LF_KEYF2> ''''
                 INTO LW_WHERE.
        ENDIF.
*       Build where clause: [KeyF3] = [KeyF3Value]
        IF <LF_KEYF3> IS ASSIGNED AND <LF_KEYF3> IS NOT INITIAL.
          CONCATENATE LW_WHERE ' AND '
                      LS_FIELD-KEYF3 ' = ''' <LF_KEYF3> ''''
                 INTO LW_WHERE.
        ENDIF.

*       Get field name in called program
        CONCATENATE '(' I_CPROG ')' LS_FIELD-TEXT_TARGET
          INTO LW_PG_FIELD.
*       Get field value
        ASSIGN (LW_PG_FIELD) TO <LF_TTARGET>.
        IF SY-SUBRC IS INITIAL
        AND LS_FIELD-TEXT_FIELD IS NOT INITIAL.
          CONCATENATE LW_FNAME LS_FIELD-TEXT_FIELD
                 INTO LW_FNAME SEPARATED BY SPACE.
          SELECT SINGLE (LW_FNAME)
            INTO (<LF_FIELD> , <LF_TTARGET>)
            FROM (LS_FIELD-TABNAME)
           WHERE (LW_WHERE).
        ELSE.
          SELECT SINGLE (LW_FNAME)
            INTO <LF_FIELD>
            FROM (LS_FIELD-TABNAME)
           WHERE (LW_WHERE).
        ENDIF.
      ENDIF.

*     Get message for invalid field:
      IF SY-SUBRC IS NOT INITIAL.
*       Set message invalid for field
        PERFORM SET_FIELD_MSG_INVALID
          USING LS_FIELD
                <LF_FIELD>
                0.
      ENDIF.
    ELSEIF <LF_FIELD> IS INITIAL.
*     Clear description value
      PERFORM CLEAR_DESC_VALUE USING LS_FIELD.

      IF LS_FIELD-CHECK_INIT = 'X'.
*       Set message required for field
        PERFORM SET_FIELD_MSG_REQUIRED
          USING LS_FIELD
                <LF_FIELD>
                0.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Export error fields to memory name:
* "[ProgramName][ScreenNo]_ERR_FIELDS"
  PERFORM ERROR_FIELDS_EXPORT
    USING I_CPROG I_DYNNR GT_ERR_FIELD I_AUTO_STOP.

  UNASSIGN <LF_FIELD>.
  T_ERR_FIELD = GT_ERR_FIELD.





ENDFUNCTION.
