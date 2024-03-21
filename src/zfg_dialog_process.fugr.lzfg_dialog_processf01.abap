*----------------------------------------------------------------------*
***INCLUDE LZFG_DIALOG_PROCESSF01 .

*&---------------------------------------------------------------------*
*&      Form  STOP_TO_SHOW_ERR
*&---------------------------------------------------------------------*
*       Stop to show error
*----------------------------------------------------------------------*
*  -->  LPW_DYNNR        Screen number
*----------------------------------------------------------------------*
FORM STOP_TO_SHOW_ERR
  USING LPW_DYNNR TYPE DYNNR.

* Stop program, use in selection screen
  IF LPW_DYNNR CP '1+++'.
*    STOP.
*    LEAVE SCREEN.
    LEAVE TO SCREEN LPW_DYNNR.
* Leave to PBO, use in normal screen
  ELSE.
    CLEAR: SY-UCOMM.
*    LEAVE TO SCREEN SY-DYNNR.
    LEAVE TO SCREEN LPW_DYNNR.
  ENDIF.
ENDFORM.                    " STOP_TO_SHOW_ERR

*&---------------------------------------------------------------------*
*&      Form  GET_FIELD_LABEL
*&---------------------------------------------------------------------*
*       Get field label of screen element
*----------------------------------------------------------------------*
*      -->LPW_FIELDNAME  Field name
*      <--LPW_SCRTEXT_L  Field label
*----------------------------------------------------------------------*
FORM GET_FIELD_LABEL
  USING  LPW_FIELDNAME TYPE CHAR61
         LPW_FIELD     TYPE ANY
         LPW_CPROG     TYPE SY-CPROG
         LPW_DYNNR     TYPE SY-DYNNR
CHANGING LPW_SCRTEXT_L TYPE SCRTEXT_L.

  DATA:
    LW_FNAME        TYPE CHAR61.

  CALL FUNCTION 'ZFM_SCR_GET_FIELD_LABEL'
    EXPORTING
      I_PROG      = LPW_CPROG
      I_DYNNR     = LPW_DYNNR
      I_FIELDNAME = LPW_FIELDNAME
      I_FIELD     = LPW_FIELD
    IMPORTING
      E_SCRTEXT_L = LPW_SCRTEXT_L.

ENDFORM.                    " GET_FIELD_LABEL

*&---------------------------------------------------------------------*
*&      Form  GET_FIELD_LABEL_ABAPDIC
*&---------------------------------------------------------------------*
*       Get field label of field from abap dictionary
*----------------------------------------------------------------------*
*      -->LPW_FIELDNAME  Field name
*      <--LPW_SCRTEXT_L  Field label
*----------------------------------------------------------------------*
FORM GET_FIELD_LABEL_ABAPDIC
  USING    LPW_FIELDNAME  TYPE CHAR61
  CHANGING LPW_SCRTEXT_L  TYPE SCRTEXT_L.

  DATA:
    LW_TABNAME TYPE TABNAME,
    LW_FNAME   TYPE FNAM_____4,
    LS_DFIES   TYPE DFIES,
    LS_DD04V   TYPE DD04V,
    LW_DATEL   TYPE DDOBJNAME.

* Init
  CLEAR LPW_SCRTEXT_L.

  IF LPW_FIELDNAME CA '-'.
*   If type is 'like', get table name, field name
    SPLIT LPW_FIELDNAME AT '-' INTO LW_TABNAME LW_FNAME.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        TABNAME        = LW_TABNAME
        LFIELDNAME     = LW_FNAME
      IMPORTING
        DFIES_WA       = LS_DFIES
      EXCEPTIONS
        NOT_FOUND      = 1
        INTERNAL_ERROR = 2
        OTHERS         = 3.
    IF SY-SUBRC IS INITIAL.
      LPW_SCRTEXT_L = LS_DFIES-SCRTEXT_L.
    ENDIF.
  ELSE.
    LW_DATEL = LPW_FIELDNAME.
*   if LPW_Fieldname Is data element, Get data element info
    CALL FUNCTION 'DDIF_DTEL_GET'
      EXPORTING
        NAME          = LW_DATEL
        LANGU         = SY-LANGU
      IMPORTING
        DD04V_WA      = LS_DD04V
      EXCEPTIONS
        ILLEGAL_INPUT = 1
        OTHERS        = 2.
    IF SY-SUBRC = 0.
      LPW_SCRTEXT_L = LS_DD04V-SCRTEXT_L.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_FIELD_LABEL_ABAPDIC

*&---------------------------------------------------------------------*
*&      Form  GET_FIELD_LABEL_PROGTEXT
*&---------------------------------------------------------------------*
*       Get Field label from program text
*----------------------------------------------------------------------*
*      -->LPW_FIELDNAME   Field name
*      -->LPW_CPROG       Call program
*      <--LPW_SCRTEXT_L   Text element
*----------------------------------------------------------------------*
FORM GET_FIELD_LABEL_PROGTEXT
  USING  LPW_FIELDNAME TYPE CHAR61
         LPW_CPROG            TYPE SY-CPROG
CHANGING LPW_SCRTEXT_L        TYPE SCRTEXT_L.

  DATA:
    LT_TEXTPOOL TYPE TABLE OF TEXTPOOL,
    LS_TEXTPOOL TYPE TEXTPOOL,
    LW_FNAME    TYPE CHAR30,
    LW_LOWHIGH  TYPE TABNAME.

* Read textpool
  READ TEXTPOOL LPW_CPROG INTO LT_TEXTPOOL LANGUAGE SY-LANGU STATE 'A'.
  IF LPW_FIELDNAME CA '-'.
*   If field is Select-Option, get field name, "LOW"-"HIGH"
    SPLIT LPW_FIELDNAME AT '-' INTO LW_FNAME LW_LOWHIGH.
  ELSE.
    LW_FNAME = LPW_FIELDNAME.
  ENDIF.
  READ TABLE LT_TEXTPOOL INTO LS_TEXTPOOL
    WITH KEY KEY = LW_FNAME.
  IF SY-SUBRC IS INITIAL
  AND LS_TEXTPOOL-ENTRY <> 'D       .'
  AND LW_FNAME IS NOT INITIAL.
    LPW_SCRTEXT_L = LS_TEXTPOOL-ENTRY.
    CONDENSE LPW_SCRTEXT_L.
  ENDIF.

ENDFORM.                    " GET_FIELD_LABEL_PROGTEXT

*&---------------------------------------------------------------------*
*&      Form  SCR_ERROR_FIELDS_EXPORT
*&---------------------------------------------------------------------*
* Export error fields to memory name:
*   "[ProgramName][ScreenNo]_ERR_FIELDS"
*----------------------------------------------------------------------*
*      -->LPW_CPROG       Program
*      -->LPW_DYNNR       Screen
*      -->LPT_ERR_FIELD   Error fields
*      -->LPW_AUTO_STOP   Autostop flag
*----------------------------------------------------------------------*
FORM SCR_ERROR_FIELDS_EXPORT
  USING    LPW_CPROG      TYPE SYCPROG
           LPW_DYNNR      TYPE DYNNR
           LPT_ERR_FIELD  TYPE ZTT_ERR_FIELD
           LPW_AUTO_STOP  TYPE XMARK
           LPW_ALERT_1ERR TYPE XMARK.
  DATA:
    LT_ERR_FIELD     TYPE ZTT_ERR_FIELD,
    LS_ERR_FIELD     TYPE ZST_ERR_FIELD,
    LT_SCR_ERR_FIELD TYPE TABLE OF GTY_SCR_ERR_FIELDS,
    LS_SCR_ERR_FIELD TYPE GTY_SCR_ERR_FIELDS,
    LW_HAS_MSG_E     TYPE XMARK.
  FIELD-SYMBOLS:
    <LF_SCR_ERR_FIELD>    TYPE GTY_SCR_ERR_FIELDS.

* Show only 1 error
  IF LPW_ALERT_1ERR = GC_XMARK
  AND LPT_ERR_FIELD IS NOT INITIAL.
    READ TABLE LPT_ERR_FIELD INTO LS_ERR_FIELD INDEX 1.
    APPEND LS_ERR_FIELD TO LT_ERR_FIELD.
    MESSAGE ID LS_ERR_FIELD-ID TYPE LS_ERR_FIELD-TYPE
            NUMBER LS_ERR_FIELD-NUMBER
       WITH LS_ERR_FIELD-MESSAGE_V1
            LS_ERR_FIELD-MESSAGE_V2
            LS_ERR_FIELD-MESSAGE_V3
            LS_ERR_FIELD-MESSAGE_V4.
  ELSE.
    LT_ERR_FIELD = LPT_ERR_FIELD.
  ENDIF.

* Collect error group by Screen number
  CLEAR: LW_HAS_MSG_E.
  LOOP AT LT_ERR_FIELD INTO LS_ERR_FIELD.
    READ TABLE LT_SCR_ERR_FIELD ASSIGNING <LF_SCR_ERR_FIELD>
      WITH KEY DYNNR = LS_ERR_FIELD-DYNNR.
    IF  SY-SUBRC IS INITIAL.
      APPEND LS_ERR_FIELD TO <LF_SCR_ERR_FIELD>-ERR_FIELDS.
    ELSE.
      CLEAR: LS_SCR_ERR_FIELD.
      LS_SCR_ERR_FIELD-DYNNR = LS_ERR_FIELD-DYNNR.
      APPEND LS_ERR_FIELD TO LS_SCR_ERR_FIELD-ERR_FIELDS.
      APPEND LS_SCR_ERR_FIELD TO LT_SCR_ERR_FIELD.
    ENDIF.
    IF LS_ERR_FIELD-TYPE = GC_MTYPE_E.
      LW_HAS_MSG_E = GC_XMARK.
    ENDIF.
  ENDLOOP.

* Export error field to corressponding screen number
  LOOP AT LT_SCR_ERR_FIELD INTO LS_SCR_ERR_FIELD.
    PERFORM ERROR_FIELDS_EXPORT
      USING LPW_CPROG
            LS_SCR_ERR_FIELD-DYNNR
            LS_SCR_ERR_FIELD-ERR_FIELDS
            SPACE.
  ENDLOOP.

* If has error and need stop to show error then stop
*  IF LPW_AUTO_STOP = 'X' AND LT_SCR_ERR_FIELD[] IS NOT INITIAL.
  IF LPW_AUTO_STOP = 'X' AND LW_HAS_MSG_E = GC_XMARK.
    PERFORM STOP_TO_SHOW_ERR USING LPW_DYNNR.
  ENDIF.
ENDFORM.                    " SCR_ERROR_FIELDS_EXPORT

*&---------------------------------------------------------------------*
*&      Form  ERROR_FIELDS_EXPORT
*&---------------------------------------------------------------------*
* Export error fields to memory name:
*   "[ProgramName][ScreenNo]_ERR_FIELDS"
*----------------------------------------------------------------------*
*      -->LPW_CPROG       Program
*      -->LPW_DYNNR       Screen
*      -->LPT_ERR_FIELD   Error fields
*      -->LPW_AUTO_STOP   Autostop flag
*----------------------------------------------------------------------*
FORM ERROR_FIELDS_EXPORT
  USING    LPW_CPROG      TYPE SYCPROG
           LPW_DYNNR      TYPE SYDYNNR
           LPT_ERR_FIELD  TYPE ZTT_ERR_FIELD
           LPW_AUTO_STOP  TYPE XMARK.
  DATA:
*   Memory ID store Error field
    LW_MEMID         TYPE CHAR70,
    LT_ERR_FIELD     TYPE ZTT_ERR_FIELD,
    LT_SCR_ERR_FIELD TYPE TABLE OF GTY_SCR_ERR_FIELDS.

  IF LPT_ERR_FIELD IS NOT INITIAL.
    CONCATENATE LPW_CPROG LPW_DYNNR '_ERR_FIELDS' INTO LW_MEMID.
    IMPORT GT_ERR_FIELD = LT_ERR_FIELD FROM MEMORY ID LW_MEMID.
    APPEND LINES OF LPT_ERR_FIELD TO LT_ERR_FIELD.
    EXPORT GT_ERR_FIELD = LT_ERR_FIELD TO MEMORY ID LW_MEMID.

    IF LPW_AUTO_STOP = 'X'.
      PERFORM STOP_TO_SHOW_ERR USING LPW_DYNNR.
    ENDIF.
  ELSE.
    FREE MEMORY ID LW_MEMID.
  ENDIF.
ENDFORM.                    " ERROR_FIELDS_EXPORT

*&---------------------------------------------------------------------*
*&      Form  ERROR_FIELDS_IMPORT
*&---------------------------------------------------------------------*
* Import error fields to memory name:
*   "[ProgramName][ScreenNo]_ERR_FIELDS"
*----------------------------------------------------------------------*
*      -->LPW_CPROG       Program
*      -->LPW_DYNNR       Screen
*      <--LPT_ERR_FIELD   Error fields
*----------------------------------------------------------------------*
FORM ERROR_FIELDS_IMPORT
  USING    LPW_CPROG      TYPE SYCPROG
           LPW_DYNNR      TYPE SYDYNNR
  CHANGING LPT_ERR_FIELD  TYPE ZTT_ERR_FIELD.
  DATA:
    LW_MEMID     TYPE CHAR70,          "Memory ID store Error field
    LT_ERR_FIELD TYPE TABLE OF ZST_ERR_FIELD.   "Error field

* Get error fields
  CONCATENATE LPW_CPROG LPW_DYNNR '_ERR_FIELDS' INTO LW_MEMID.
  IMPORT GT_ERR_FIELD = LPT_ERR_FIELD FROM MEMORY ID LW_MEMID.
  APPEND LINES OF GT_ERR_FIELD TO LPT_ERR_FIELD.
  DELETE GT_ERR_FIELD WHERE DYNNR = LPW_DYNNR.
  DELETE LPT_ERR_FIELD WHERE DYNNR <> LPW_DYNNR.
  SORT LPT_ERR_FIELD BY FPOSI.
  FREE MEMORY ID LW_MEMID.
ENDFORM.                    " ERROR_FIELDS_IMPORT

*&---------------------------------------------------------------------*
*&      Form  ERROR_FIELDS_IMPORT
*&---------------------------------------------------------------------*
* Import error fields to memory name:
*   "[ProgramName][ScreenNo]_ERR_FIELDS"
*----------------------------------------------------------------------*
*      -->LPW_CPROG       Program
*      -->LPW_DYNNR       Screen
*      <--LPT_ERR_FIELD   Error fields
*----------------------------------------------------------------------*
FORM ERROR_FIELDS_TAB_IMPORT
  USING    LPW_CPROG      TYPE SYCPROG
           LPW_DYNNR      TYPE SYDYNNR
           LPW_TABCONTROL TYPE ZDD_TABCONTROL
  CHANGING LPT_ERR_FIELD  TYPE ZTT_ERR_FIELD.
  DATA:
    LW_MEMID     TYPE CHAR70,          "Memory ID store Error field
    LT_ERR_FIELD TYPE TABLE OF ZST_ERR_FIELD.   "Error field

* Get error fields
  CONCATENATE LPW_CPROG LPW_DYNNR '_ERR_FIELDS' INTO LW_MEMID.
*  IMPORT GT_ERR_FIELD = LPT_ERR_FIELD FROM MEMORY ID LW_MEMID.
  IMPORT GT_ERR_FIELD = LT_ERR_FIELD FROM MEMORY ID LW_MEMID.
  APPEND LINES OF LT_ERR_FIELD TO GT_ERR_FIELD.
  APPEND LINES OF GT_ERR_FIELD TO LPT_ERR_FIELD.
  DELETE GT_ERR_FIELD
    WHERE DYNNR = LPW_DYNNR AND TABCONTROL = LPW_TABCONTROL.
  DELETE LPT_ERR_FIELD
    WHERE DYNNR <> LPW_DYNNR OR TABCONTROL <> LPW_TABCONTROL.
  SORT LPT_ERR_FIELD BY FPOSI.
  FREE MEMORY ID LW_MEMID.
ENDFORM.                    " ERROR_FIELDS_IMPORT

*&---------------------------------------------------------------------*
*&      Form  HIGHLIGHT_FIELDS_EXPORT
*&---------------------------------------------------------------------*
* Export error fields to memory name:
*   "[ProgramName][ScreenNo]_ERR_FIELDS"
*----------------------------------------------------------------------*
*      -->LPW_CPROG       Program
*      -->LPW_DYNNR       Screen
*      -->LPT_HL_FIELD    Highlight fields
*----------------------------------------------------------------------*
FORM HIGHLIGHT_FIELDS_EXPORT
  USING    LPW_CPROG      TYPE SYCPROG
           LPW_DYNNR      TYPE SYDYNNR
           LPT_HL_FIELD   TYPE ZTT_ERR_FIELD.
  DATA:
*   Memory ID store Error field
    LW_MEMID        TYPE CHAR70,
    LT_OLD_HL_FIELD TYPE ZTT_ERR_FIELD.

  IF LPT_HL_FIELD IS NOT INITIAL.
    CONCATENATE LPW_CPROG LPW_DYNNR '_HL_FIELDS' INTO LW_MEMID.
    IMPORT GT_HL_FIELD = LT_OLD_HL_FIELD FROM MEMORY ID LW_MEMID.
    APPEND LINES OF LT_OLD_HL_FIELD TO LPT_HL_FIELD.
    EXPORT GT_HL_FIELD = LPT_HL_FIELD TO MEMORY ID LW_MEMID.
  ELSE.
    FREE MEMORY ID LW_MEMID.
  ENDIF.
ENDFORM.                    " HIGHLIGHT_FIELDS_EXPORT

*&---------------------------------------------------------------------*
*&      Form  HIGHLIGHT_FIELDS_IMPORT
*&---------------------------------------------------------------------*
* Import error fields to memory name:
*   "[ProgramName][ScreenNo]_HL_FIELDS"
*----------------------------------------------------------------------*
*      -->LPW_CPROG       Program
*      -->LPW_DYNNR       Screen
*      <--LPT_ERR_FIELD   Error fields
*----------------------------------------------------------------------*
FORM HIGHLIGHT_FIELDS_IMPORT
  USING    LPW_CPROG      TYPE SYCPROG
           LPW_DYNNR      TYPE SYDYNNR
  CHANGING LPT_HL_FIELD   TYPE ZTT_ERR_FIELD.
  DATA:
    LW_MEMID      TYPE CHAR70.

* Get error fields
  CONCATENATE LPW_CPROG LPW_DYNNR '_HL_FIELDS' INTO LW_MEMID.
  IMPORT GT_HL_FIELD = LPT_HL_FIELD FROM MEMORY ID LW_MEMID.
  FREE MEMORY ID LW_MEMID.
ENDFORM.                    " HIGHLIGHT_FIELDS_IMPORT

*&---------------------------------------------------------------------*
*&      Form  SET_DESC_VALUE
*&---------------------------------------------------------------------*
*       Set description of field to description target
*----------------------------------------------------------------------*
*      -->LPS_FIELD  text
*      -->LPS_RECORD  text
*----------------------------------------------------------------------*
FORM SET_DESC_VALUE
  USING    LPS_FIELD  TYPE ZTB_FIELD_DB
           LPS_RECORD TYPE ANY.
  DATA:
    LW_PG_FIELD   TYPE CHAR100,
    LS_FIELD_DESC TYPE ZTB_FIELD_DESC.

  FIELD-SYMBOLS:
    <LF_TTARGET> TYPE ANY,          "Text target in call program
    <LF_TVALUE>  TYPE ANY.          "Text value

* Set description
  IF LPS_FIELD-TEXT_FIELD IS NOT INITIAL
  AND LPS_FIELD-TEXT_TARGET IS NOT INITIAL.
    ASSIGN COMPONENT LPS_FIELD-TEXT_FIELD OF STRUCTURE LPS_RECORD
    TO <LF_TVALUE>.
    IF SY-SUBRC IS INITIAL.
*     Get field name in called program
      CONCATENATE '(' LPS_FIELD-REPID ')' LPS_FIELD-TEXT_TARGET
        INTO LW_PG_FIELD.
*     Get field value
      ASSIGN (LW_PG_FIELD) TO <LF_TTARGET>.
      IF SY-SUBRC IS INITIAL.
        <LF_TTARGET> = <LF_TVALUE>.
      ENDIF.
    ENDIF.
  ENDIF.

* Set description list
  LOOP AT GT_FIELD_DESC INTO LS_FIELD_DESC
    WHERE DYNNR = LPS_FIELD-DYNNR AND FIELDNAME = LPS_FIELD-FIELDNAME.
    ASSIGN COMPONENT LS_FIELD_DESC-TEXT_FIELD OF STRUCTURE LPS_RECORD
    TO <LF_TVALUE>.
    IF SY-SUBRC IS INITIAL.
*     Get field name in called program
      CONCATENATE '(' LS_FIELD_DESC-REPID ')' LS_FIELD_DESC-TEXT_TARGET
        INTO LW_PG_FIELD.
*     Get field value
      ASSIGN (LW_PG_FIELD) TO <LF_TTARGET>.
      IF SY-SUBRC IS INITIAL.
        <LF_TTARGET> = <LF_TVALUE>.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SET_DESC_VALUE

*&---------------------------------------------------------------------*
*&      Form  CLEAR_DESC_VALUE
*&---------------------------------------------------------------------*
*       Clear description of field
*----------------------------------------------------------------------*
*      -->LPS_FIELD  text
*      -->LPS_RECORD  text
*----------------------------------------------------------------------*
FORM CLEAR_DESC_VALUE USING    LPS_FIELD  TYPE ZTB_FIELD_DB.
  DATA: LW_PG_FIELD       TYPE CHAR100.
  FIELD-SYMBOLS: <LF_TTARGET>      TYPE ANY.
  "Text target in call program

*----------------------------------------------------*
* Clear description
  IF LPS_FIELD-TEXT_FIELD IS NOT INITIAL
  AND LPS_FIELD-TEXT_TARGET IS NOT INITIAL.
*   Get field name in called program
    CONCATENATE '(' LPS_FIELD-REPID ')' LPS_FIELD-TEXT_TARGET
      INTO LW_PG_FIELD.
*   Get field value
    ASSIGN (LW_PG_FIELD) TO <LF_TTARGET>.
    IF SY-SUBRC IS INITIAL.
      CLEAR <LF_TTARGET>.
    ENDIF.
  ENDIF.
ENDFORM.                    " CLEAR_DESC_VALUE

*&---------------------------------------------------------------------*
*&      Form  SET_FIELD_MSG_INVALID
*&---------------------------------------------------------------------*
*       Set message invalid for field
*----------------------------------------------------------------------*
*      -->LPS_FIELD  Field info
*      <--LPW_FIELD  Field
*----------------------------------------------------------------------*
FORM SET_FIELD_MSG_INVALID
  USING    LPS_FIELD        TYPE ZTB_FIELD_DB
           VALUE(LPW_FIELD) TYPE ANY
           LPW_ROW          TYPE I.
  DATA:
    LS_ERR_FIELD TYPE ZST_ERR_FIELD,
    LW_SCRTEXT_L TYPE SCRTEXT_L.

* Example: Message E002(ZMS_COL_LIB) with Field name
  IF LPS_FIELD-SUBSCR IS INITIAL.
    LS_ERR_FIELD-DYNNR      = LPS_FIELD-DYNNR.
  ELSE.
    LS_ERR_FIELD-DYNNR      = LPS_FIELD-SUBSCR.
  ENDIF.
  LS_ERR_FIELD-TYPE       = GC_MTYPE_E.
  LS_ERR_FIELD-ID         = GC_MSG_CL.
  LS_ERR_FIELD-NUMBER     = GC_MSGNR_INVALID.
  LS_ERR_FIELD-FIELD      = LPS_FIELD-FIELDNAME.
  LS_ERR_FIELD-ROW        = LPW_ROW.
  LS_ERR_FIELD-FPOSI      = LPS_FIELD-FPOSI.
  LS_ERR_FIELD-TABCONTROL = LPS_FIELD-TABCONTROL.

  PERFORM GET_FIELD_LABEL
    USING  LPS_FIELD-FIELDNAME
           LPW_FIELD
           LPS_FIELD-REPID
           LPS_FIELD-DYNNR
    CHANGING LW_SCRTEXT_L.
  LS_ERR_FIELD-MESSAGE_V1 = LW_SCRTEXT_L.
  CALL FUNCTION 'ZFM_SCR_FIELD_CONVERT_TO_OUT'
    EXPORTING
      I_FIELDNAME = LPS_FIELD-FIELDNAME
    CHANGING
      C_FIELD     = LPW_FIELD.

  LS_ERR_FIELD-MESSAGE_V2 = LPW_FIELD.

  APPEND LS_ERR_FIELD TO GT_ERR_FIELD.
ENDFORM.                    " SET_FIELD_MSG_INVALID

*&---------------------------------------------------------------------*
*&      Form  SET_FIELD_MSG_REQUIRED
*&---------------------------------------------------------------------*
*       Set message required for field
*----------------------------------------------------------------------*
*      -->LPS_FIELD  Field info
*      -->LPW_FIELD  Field
*      -->LPW_ROW    Row in table contrl
*----------------------------------------------------------------------*
FORM SET_FIELD_MSG_REQUIRED
  USING    LPS_FIELD TYPE ZTB_FIELD_DB
           LPW_FIELD TYPE ANY
           LPW_ROW   TYPE I.
  DATA:
    LS_ERR_FIELD TYPE ZST_ERR_FIELD,
    LW_SCRTEXT_L TYPE SCRTEXT_L.

* Example: Message E001(ZMS_COL_LIB) with Field name
  IF LPS_FIELD-SUBSCR IS INITIAL.
    LS_ERR_FIELD-DYNNR    = LPS_FIELD-DYNNR.
  ELSE.
    LS_ERR_FIELD-DYNNR    = LPS_FIELD-SUBSCR.
  ENDIF.
  LS_ERR_FIELD-TYPE       = GC_MTYPE_E.
  LS_ERR_FIELD-ID         = GC_MSG_CL.
  LS_ERR_FIELD-NUMBER     = GC_MSGNR_REQUIRED.
  LS_ERR_FIELD-FIELD      = LPS_FIELD-FIELDNAME.
  LS_ERR_FIELD-ROW        = LPW_ROW.
  LS_ERR_FIELD-FPOSI      = LPS_FIELD-FPOSI.
  LS_ERR_FIELD-TABCONTROL = LPS_FIELD-TABCONTROL.

* Get field label
  PERFORM GET_FIELD_LABEL
    USING  LPS_FIELD-FIELDNAME
           LPW_FIELD
           LPS_FIELD-REPID
           LPS_FIELD-DYNNR
  CHANGING LW_SCRTEXT_L.
  LS_ERR_FIELD-MESSAGE_V1 = LW_SCRTEXT_L.

  APPEND LS_ERR_FIELD TO GT_ERR_FIELD.

ENDFORM.                    " SET_FIELD_MSG_REQUIRED

*&---------------------------------------------------------------------*
*&      Form  SET_FIELD_MSG_REQUIRED_W
*&---------------------------------------------------------------------*
*       Set message required for field
*----------------------------------------------------------------------*
*      -->LPS_FIELD  Field info
*      -->LPW_FIELD  Field
*      -->LPW_ROW    Row in table contrl
*----------------------------------------------------------------------*
FORM SET_FIELD_MSG_REQUIRED_W
  USING    LPS_FIELD TYPE ZTB_FIELD_DB
           LPW_FIELD TYPE ANY
           LPW_ROW   TYPE I.
  DATA:
    LS_ERR_FIELD TYPE ZST_ERR_FIELD,
    LW_SCRTEXT_L TYPE SCRTEXT_L.

* Example: Message E001(ZMS_COL_LIB) with Field name
  IF LPS_FIELD-SUBSCR IS INITIAL.
    LS_ERR_FIELD-DYNNR    = LPS_FIELD-DYNNR.
  ELSE.
    LS_ERR_FIELD-DYNNR    = LPS_FIELD-SUBSCR.
  ENDIF.
  LS_ERR_FIELD-TYPE       = GC_MTYPE_W.
  LS_ERR_FIELD-ID         = GC_MSG_CL.
  LS_ERR_FIELD-NUMBER     = GC_MSGNR_REQUIRED.
  LS_ERR_FIELD-FIELD      = LPS_FIELD-FIELDNAME.
  LS_ERR_FIELD-ROW        = LPW_ROW.
  LS_ERR_FIELD-FPOSI      = LPS_FIELD-FPOSI.
  LS_ERR_FIELD-TABCONTROL = LPS_FIELD-TABCONTROL.

* Get field label
  PERFORM GET_FIELD_LABEL
    USING  LPS_FIELD-FIELDNAME
           LPW_FIELD
           LPS_FIELD-REPID
           LPS_FIELD-DYNNR
  CHANGING LW_SCRTEXT_L.
  LS_ERR_FIELD-MESSAGE_V1 = LW_SCRTEXT_L.

  APPEND LS_ERR_FIELD TO GT_ERR_FIELD.

ENDFORM.                    " SET_FIELD_MSG_REQUIRED_W

*&---------------------------------------------------------------------*
*&      Form  GET_FIELD_VALUE_CPROG
*&---------------------------------------------------------------------*
*   Get field value in called program
*----------------------------------------------------------------------*
*  -->  LPS_FIELD        Field info
*  <--  LPW_FIELDVAL    Field value
*----------------------------------------------------------------------*
FORM GET_FIELD_VALUE_CPROG
  USING     LPS_FIELD     TYPE ZTB_FIELD_DB
  CHANGING  LPW_FIELDVAL  TYPE ANY.
  DATA:
*   Program field: ([PgName])FName
    LW_PG_FIELD   TYPE CHAR100.
  FIELD-SYMBOLS:
    <LF_FIELD>    TYPE ANY.

* Get field reference in called program
  CONCATENATE '(' LPS_FIELD-REPID ')'
              LPS_FIELD-FIELDNAME
         INTO LW_PG_FIELD.
  ASSIGN (LW_PG_FIELD) TO <LF_FIELD>.
  LPW_FIELDVAL = <LF_FIELD>.
ENDFORM.                    " GET_FIELD_VALUE_CPROG

*&---------------------------------------------------------------------*
*&      Form  PAI_PROCESS_EACH_FIELD
*&---------------------------------------------------------------------*
*       Process each field on screen
*----------------------------------------------------------------------*
*  -->  LPS_FIELD        Field info
*  -->  LPW_INITIAL      Initial flag
*  -->  LPW_NO_CHECK     No check data
*  -->  LPW_ROW          Row on table control
*----------------------------------------------------------------------*
FORM PAI_PROCESS_EACH_FIELD
  USING LPS_FIELD     TYPE ZTB_FIELD_DB
        LPW_INITIAL   TYPE XMARK
        LPW_NO_CHECK  TYPE XMARK
        I_WARN_REQUIRED TYPE XMARK
        LPW_ROW       TYPE I
        LPT_CHKSTEP   TYPE  ZTT_SCR_CHKSTEP.

  DATA:
    LS_FIELD     TYPE ZTB_FIELD_DB, "Field info need check value
    LW_PG_FIELD  TYPE CHAR100,     "Program field: ([PgName])FName
    LW_CTABNM    TYPE CHAR100,     "Local check table name
    LW_FNAME     TYPE FIELDNAME,   "Field name
    LW_WHERE     TYPE STRING,      "Where clause
    LW_VALID_VAL TYPE XMARK        "Value of field is valid
    .
  FIELD-SYMBOLS:
    <LFT_CTAB>   TYPE ANY TABLE,       "Local check table
    <LF_RECORD>  TYPE ANY,             "Record of field if exist
    <LF_FIELD>   TYPE ANY,             "Field value
    <LF_KEYF1>   TYPE ANY,             "Key field 1
    <LF_KEYF2>   TYPE ANY,             "Key field 2
    <LF_KEYF3>   TYPE ANY,             "Key field 3
    <LF_TTARGET> TYPE ANY.             "Text target in call program

* Init
  LS_FIELD          = LPS_FIELD.

* Get field reference in called program
  CONCATENATE '(' LS_FIELD-REPID ')' LS_FIELD-FIELDNAME
         INTO LW_PG_FIELD.
  ASSIGN (LW_PG_FIELD) TO <LF_FIELD>.
  CHECK SY-SUBRC IS INITIAL.

* Set init value for field
  IF LPW_INITIAL = GC_XMARK.
*   Set init value for screen field
    PERFORM INIT_SET_VALUE_FOR_FIELD
      USING LPS_FIELD
    CHANGING <LF_FIELD>.

*   Set label text of field if need
    PERFORM INIT_SET_LABEL_TEXT USING LPS_FIELD <LF_FIELD>.
  ENDIF.

* Clear description, and check required field
  IF <LF_FIELD> IS INITIAL.
    READ TABLE LPT_CHKSTEP TRANSPORTING NO FIELDS
      WITH KEY CSTEP = LS_FIELD-CSTEP.
    IF SY-SUBRC IS INITIAL
    OR LPT_CHKSTEP[] IS INITIAL.
*     Clear description value
      PERFORM CLEAR_DESC_VALUE USING LS_FIELD.
    ENDIF.

*   Check field is required
    IF LS_FIELD-CHECK_INIT = 'X'
    AND LPW_NO_CHECK IS INITIAL.
*     if field need check
      READ TABLE LPT_CHKSTEP TRANSPORTING NO FIELDS
        WITH KEY CSTEP = LS_FIELD-CSTEP.
      IF SY-SUBRC IS INITIAL
      OR LPT_CHKSTEP[] IS INITIAL.
        PERFORM SCROLL_TABCONTROL_TO_ERR
          USING LS_FIELD
                1.
        IF I_WARN_REQUIRED IS INITIAL.
*         Set message required for field
          PERFORM SET_FIELD_MSG_REQUIRED
            USING LS_FIELD
                  <LF_FIELD>
                  LPW_ROW.
        ELSE.
*         Set message required for field
          PERFORM SET_FIELD_MSG_REQUIRED_W
            USING LS_FIELD
                  <LF_FIELD>
                  LPW_ROW.
        ENDIF.
*       Quit check
        RETURN.
      ENDIF.
    ENDIF.
* Set description, and check input value is valid
  ELSEIF <LF_FIELD> IS NOT INITIAL
     AND LS_FIELD-TABNAME IS NOT INITIAL.

    READ TABLE LPT_CHKSTEP TRANSPORTING NO FIELDS
      WITH KEY CSTEP = LS_FIELD-CSTEP.
    CHECK SY-SUBRC IS INITIAL.

    CLEAR: LW_VALID_VAL.
*   Get component name of field in check table
    IF LS_FIELD-KEYF1 IS NOT INITIAL.
      LW_FNAME = LS_FIELD-KEYF1.
    ELSE.
*     Get field type name
      DESCRIBE FIELD <LF_FIELD> HELP-ID LW_FNAME.
*     Get component name in structure
      IF LW_FNAME CS '-'.
        SPLIT LW_FNAME AT '-' INTO LW_FNAME LW_FNAME.
      ENDIF.
    ENDIF.

*   Get parents value in called program
    IF LS_FIELD-PRFIELD2 IS NOT INITIAL.
*     Get Parents field value in called program
      CONCATENATE '(' LS_FIELD-REPID ')'  LS_FIELD-PRFIELD2
             INTO LW_PG_FIELD.
      ASSIGN (LW_PG_FIELD) TO <LF_KEYF2>.
    ENDIF.
    IF LS_FIELD-PRFIELD3 IS NOT INITIAL.
*     Get Parents field value in called program
      CONCATENATE '(' LS_FIELD-REPID ')' LS_FIELD-PRFIELD3
             INTO LW_PG_FIELD.
      ASSIGN (LW_PG_FIELD) TO <LF_KEYF3>.
    ENDIF.

*   Retrieve data using: Local check table in called program
    IF LS_FIELD-TABNAME CS '[]'.
      CONCATENATE '(' LS_FIELD-REPID ')' LS_FIELD-TABNAME
             INTO LW_CTABNM.
    ELSE.
      CONCATENATE '(' LS_FIELD-REPID ')' LS_FIELD-TABNAME '[]'
             INTO LW_CTABNM.
    ENDIF.
    ASSIGN (LW_CTABNM) TO <LFT_CTAB>.
    IF SY-SUBRC IS INITIAL.
      IF  <LF_KEYF2> IS ASSIGNED AND <LF_KEYF2> IS NOT INITIAL
      AND <LF_KEYF3> IS ASSIGNED AND <LF_KEYF3> IS NOT INITIAL.
*       Search data from local check table
        READ TABLE <LFT_CTAB> ASSIGNING <LF_RECORD>
          WITH KEY (LW_FNAME)       = <LF_FIELD>
                   (LS_FIELD-KEYF2) = <LF_KEYF2>
                   (LS_FIELD-KEYF3) = <LF_KEYF3>.
      ELSEIF <LF_KEYF2> IS ASSIGNED AND <LF_KEYF2> IS NOT INITIAL.
*       Search data from local check table
        READ TABLE <LFT_CTAB> ASSIGNING <LF_RECORD>
          WITH KEY (LW_FNAME)       = <LF_FIELD>
                   (LS_FIELD-KEYF2) = <LF_KEYF2>.
      ELSE.
*       Search data from local check table
        READ TABLE <LFT_CTAB> ASSIGNING <LF_RECORD>
          WITH KEY (LW_FNAME)       = <LF_FIELD>.
      ENDIF.

*     Set flag: value of field is valid and set description
      IF SY-SUBRC IS INITIAL.
        LW_VALID_VAL = GC_XMARK.
        PERFORM SET_DESC_VALUE USING LS_FIELD <LF_RECORD>.
      ENDIF.

*--------------------------------------------------------------------*
*   Retrieve data using: DB table
    ELSE.
*     Build where clause: [Fieldname] = [Fieldvalue]
      CONCATENATE LW_FNAME ' = ''' <LF_FIELD> '''' INTO LW_WHERE.
*     Build where clause: [KeyF2] = [KeyF2Value]
      IF <LF_KEYF2> IS ASSIGNED AND <LF_KEYF2> IS NOT INITIAL.
        CONCATENATE LW_WHERE ' AND '
                    LS_FIELD-KEYF2 ' = ''' <LF_KEYF2> ''''
               INTO LW_WHERE RESPECTING BLANKS.
      ENDIF.
*     Build where clause: [KeyF3] = [KeyF3Value]
      IF <LF_KEYF3> IS ASSIGNED AND <LF_KEYF3> IS NOT INITIAL.
        CONCATENATE LW_WHERE ' AND '
                    LS_FIELD-KEYF3 ' = ''' <LF_KEYF3> ''''
               INTO LW_WHERE RESPECTING BLANKS.
      ENDIF.

*     Get field name in called program
      CONCATENATE '(' LS_FIELD-REPID ')' LS_FIELD-TEXT_TARGET
             INTO LW_PG_FIELD.
*     Get field value
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
      IF SY-SUBRC IS INITIAL.
        LW_VALID_VAL = GC_XMARK.
      ENDIF.
    ENDIF.

    IF LW_VALID_VAL IS INITIAL.
*     Clear description value
      PERFORM CLEAR_DESC_VALUE USING LS_FIELD.

*     Get message for invalid field:
      IF LPW_NO_CHECK IS INITIAL.
        PERFORM SCROLL_TABCONTROL_TO_ERR
          USING LS_FIELD
                1.
*       Set message invalid for field
        PERFORM SET_FIELD_MSG_INVALID
          USING LS_FIELD
                <LF_FIELD>
                LPW_ROW.
*       Quit check
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

  IF LPW_NO_CHECK IS INITIAL AND
     LS_FIELD-CKSUBR IS NOT INITIAL.
*   if field need check
    READ TABLE LPT_CHKSTEP TRANSPORTING NO FIELDS
      WITH KEY CSTEP = LS_FIELD-CSTEP.
    IF SY-SUBRC IS INITIAL OR LPT_CHKSTEP IS INITIAL.
*     Set check row before call check subroutine
      GW_CURR_CHECKROW  = LPW_ROW.
      PERFORM (LS_FIELD-CKSUBR) IN PROGRAM (LS_FIELD-REPID) IF FOUND.
    ENDIF.
  ENDIF.

ENDFORM.                    " PAI_PROCESS_EACH_FIELD
*&---------------------------------------------------------------------*
*&      Form  PAI_PROCESS_EACH_FIELD_SCR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_FIELD        text
*      -->LPW_INITIAL      text
*      -->LPW_NO_CHECK     text
*      -->I_WARN_REQUIRED  text
*      -->LPW_ROW          text
*      -->LPT_CHKSTEP      text
*      -->LPW_REPID_DATA   text
*----------------------------------------------------------------------*
FORM PAI_PROCESS_EACH_FIELD_SCR USING LPS_FIELD       TYPE ZTB_FIELD_DB
                                      LPW_INITIAL     TYPE XMARK
                                      LPW_NO_CHECK    TYPE XMARK
                                      I_WARN_REQUIRED TYPE XMARK
                                      LPW_ROW         TYPE I
                                   LPT_CHKSTEP     TYPE  ZTT_SCR_CHKSTEP
                                   LPW_REPID_DATA  TYPE SY-CPROG.
  DATA: LS_FIELD     TYPE ZTB_FIELD_DB,    "Field info need check value
        LW_PG_FIELD  TYPE CHAR100,         "Program field: ([PgName])FName
        LW_CTABNM    TYPE CHAR100,         "Local check table name
        LW_FNAME     TYPE FIELDNAME,       "Field name
        LW_WHERE     TYPE STRING,          "Where clause
        LW_VALID_VAL TYPE XMARK.           "Value of field is valid

  FIELD-SYMBOLS: <LFT_CTAB>   TYPE ANY TABLE,       "Local check table
                 <LF_RECORD>  TYPE ANY,             "Record of field if exist
                 <LF_FIELD>   TYPE ANY,             "Field value
                 <LF_KEYF1>   TYPE ANY,             "Key field 1
                 <LF_KEYF2>   TYPE ANY,             "Key field 2
                 <LF_KEYF3>   TYPE ANY,             "Key field 3
                 <LF_TTARGET> TYPE ANY.             "Text target in call program

*----------------------------------------------------*
* Init
  LS_FIELD = LPS_FIELD.

* Get field reference in called program
  CONCATENATE '(' LPW_REPID_DATA ')' LS_FIELD-FIELDNAME
         INTO LW_PG_FIELD.
  ASSIGN (LW_PG_FIELD) TO <LF_FIELD>.
  CHECK SY-SUBRC IS INITIAL.

*----------------------------------------------------*
* Set init value for field
*----------------------------------------------------*
  IF LPW_INITIAL = GC_XMARK.
*   Set init value for screen field
    PERFORM INIT_SET_VALUE_FOR_FIELD  USING LPS_FIELD
                                      CHANGING <LF_FIELD>.

*   Set label text of field if need
    PERFORM INIT_SET_LABEL_TEXT USING LPS_FIELD <LF_FIELD>.
  ENDIF.

*----------------------------------------------------*
* Clear description, and check required field
*----------------------------------------------------*
  IF <LF_FIELD> IS INITIAL.
*   Clear description value
    PERFORM CLEAR_DESC_VALUE USING LS_FIELD.

*   Check field is required
    IF LS_FIELD-CHECK_INIT = GC_XMARK
    AND LPW_NO_CHECK IS INITIAL.
*     if field need check
      READ TABLE LPT_CHKSTEP TRANSPORTING NO FIELDS WITH KEY
           CSTEP = LS_FIELD-CSTEP.
      IF SY-SUBRC IS INITIAL
      OR LPT_CHKSTEP[] IS INITIAL.
        PERFORM SCROLL_TABCONTROL_TO_ERR
          USING LS_FIELD
                1.
        IF I_WARN_REQUIRED IS INITIAL.
*         Set message required for field
          PERFORM SET_FIELD_MSG_REQUIRED
            USING LS_FIELD
                  <LF_FIELD>
                  LPW_ROW.
        ELSE.
*         Set message required for field
          PERFORM SET_FIELD_MSG_REQUIRED_W
            USING LS_FIELD
                  <LF_FIELD>
                  LPW_ROW.
        ENDIF.
*       Quit check
        RETURN.
      ENDIF.
    ENDIF.
* Set description, and check input value is valid
  ELSEIF <LF_FIELD> IS NOT INITIAL
     AND LS_FIELD-TABNAME IS NOT INITIAL.
    CLEAR LW_VALID_VAL.
*   Get component name of field in check table
    IF LS_FIELD-KEYF1 IS NOT INITIAL.
      LW_FNAME = LS_FIELD-KEYF1.
    ELSE.
*     Get field type name
      DESCRIBE FIELD <LF_FIELD> HELP-ID LW_FNAME.
*     Get component name in structure
      IF LW_FNAME CS '-'.
        SPLIT LW_FNAME AT '-' INTO LW_FNAME LW_FNAME.
      ENDIF.
    ENDIF.

*   Get parents value in called program
    IF LS_FIELD-PRFIELD2 IS NOT INITIAL.
*     Get Parents field value in called program
      CONCATENATE '(' LS_FIELD-REPID ')'  LS_FIELD-PRFIELD2
             INTO LW_PG_FIELD.
      ASSIGN (LW_PG_FIELD) TO <LF_KEYF2>.
    ENDIF.
    IF LS_FIELD-PRFIELD3 IS NOT INITIAL.
*     Get Parents field value in called program
      CONCATENATE '(' LS_FIELD-REPID ')' LS_FIELD-PRFIELD3
             INTO LW_PG_FIELD.
      ASSIGN (LW_PG_FIELD) TO <LF_KEYF3>.
    ENDIF.

* Retrieve data using: Local check table in called program
    CONCATENATE '(' LPW_REPID_DATA ')' LS_FIELD-TABNAME INTO LW_CTABNM.
    ASSIGN (LW_CTABNM) TO <LFT_CTAB>.
    IF SY-SUBRC IS INITIAL.
      IF  <LF_KEYF2> IS ASSIGNED AND <LF_KEYF2> IS NOT INITIAL
      AND <LF_KEYF3> IS ASSIGNED AND <LF_KEYF3> IS NOT INITIAL.
*       Search data from local check table
        READ TABLE <LFT_CTAB> ASSIGNING <LF_RECORD>
          WITH KEY (LW_FNAME)       = <LF_FIELD>
                   (LS_FIELD-KEYF2) = <LF_KEYF2>
                   (LS_FIELD-KEYF3) = <LF_KEYF3>.
      ELSEIF <LF_KEYF2> IS ASSIGNED AND <LF_KEYF2> IS NOT INITIAL.
*       Search data from local check table
        READ TABLE <LFT_CTAB> ASSIGNING <LF_RECORD>
          WITH KEY (LW_FNAME)       = <LF_FIELD>
                   (LS_FIELD-KEYF2) = <LF_KEYF2>.
      ELSE.
*       Search data from local check table
        READ TABLE <LFT_CTAB> ASSIGNING <LF_RECORD>
          WITH KEY (LW_FNAME)       = <LF_FIELD>.
      ENDIF.

*     Set flag: value of field is valid and set description
      IF SY-SUBRC IS INITIAL.
        LW_VALID_VAL = GC_XMARK.
        PERFORM SET_DESC_VALUE USING LS_FIELD <LF_RECORD>.
      ENDIF.
*--------------------------------------------------------------------*
*   Retrieve data using: DB table
    ELSE.
*     Build where clause: [Fieldname] = [Fieldvalue]
      CONCATENATE LW_FNAME ' = ''' <LF_FIELD> '''' INTO LW_WHERE.
*     Build where clause: [KeyF2] = [KeyF2Value]
      IF <LF_KEYF2> IS ASSIGNED AND <LF_KEYF2> IS NOT INITIAL.
        CONCATENATE LW_WHERE ' AND '
                    LS_FIELD-KEYF2 ' = ''' <LF_KEYF2> ''''
               INTO LW_WHERE.
      ENDIF.
*     Build where clause: [KeyF3] = [KeyF3Value]
      IF <LF_KEYF3> IS ASSIGNED AND <LF_KEYF3> IS NOT INITIAL.
        CONCATENATE LW_WHERE ' AND '
                    LS_FIELD-KEYF3 ' = ''' <LF_KEYF3> ''''
               INTO LW_WHERE.
      ENDIF.

*     Get field name in called program
      CONCATENATE '(' LS_FIELD-REPID ')' LS_FIELD-TEXT_TARGET
             INTO LW_PG_FIELD.
*     Get field value
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
      IF SY-SUBRC IS INITIAL.
        LW_VALID_VAL = GC_XMARK.
      ENDIF.
    ENDIF.

    IF LW_VALID_VAL IS INITIAL.
*     Clear description value
      PERFORM CLEAR_DESC_VALUE USING LS_FIELD.

*     Get message for invalid field:
      IF LPW_NO_CHECK IS INITIAL.
        PERFORM SCROLL_TABCONTROL_TO_ERR
          USING LS_FIELD
                1.
*       Set message invalid for field
        PERFORM SET_FIELD_MSG_INVALID
          USING LS_FIELD
                <LF_FIELD>
                LPW_ROW.
*       Quit check
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

  IF LPW_NO_CHECK IS INITIAL AND
     LS_FIELD-CKSUBR IS NOT INITIAL.
*   Set check row before call check subroutine
    GW_CURR_CHECKROW  = LPW_ROW.
    PERFORM (LS_FIELD-CKSUBR) IN PROGRAM (LPW_REPID_DATA) IF FOUND.
  ENDIF.
ENDFORM.                    " PAI_PROCESS_EACH_FIELD
*&---------------------------------------------------------------------*
*&      Form  PAI_SCR_PROCESS_EACH_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_FIELD        text
*      -->LPW_INITIAL      text
*      -->LPW_NO_CHECK     text
*      -->I_WARN_REQUIRED  text
*      -->LPW_ROW          text
*      -->LPT_CHKSTEP      text
*      -->LPW_REPID        text
*----------------------------------------------------------------------*
FORM PAI_SCR_PROCESS_EACH_FIELD USING LPS_FIELD     TYPE ZTB_FIELD_DB
                                      LPW_INITIAL   TYPE XMARK
                                      LPW_NO_CHECK  TYPE XMARK
                                      I_WARN_REQUIRED TYPE XMARK
                                      LPW_ROW       TYPE I
                                      LPT_CHKSTEP   TYPE ZTT_SCR_CHKSTEP
                                      LPW_REPID     TYPE CPROG.
  DATA: LS_FIELD     TYPE ZTB_FIELD_DB,    "Field info need check value
        LW_PG_FIELD  TYPE CHAR100,         "Program field: ([PgName])FName
        LW_CTABNM    TYPE CHAR100,         "Local check table name
        LW_FNAME     TYPE FIELDNAME,       "Field name
        LW_WHERE     TYPE STRING,          "Where clause
        LW_VALID_VAL TYPE XMARK.            "Value of field is valid
  FIELD-SYMBOLS: <LFT_CTAB>   TYPE ANY TABLE,       "Local check table
                 <LF_RECORD>  TYPE ANY,             "Record of field if exist
                 <LF_FIELD>   TYPE ANY,             "Field value
                 <LF_KEYF1>   TYPE ANY,             "Key field 1
                 <LF_KEYF2>   TYPE ANY,             "Key field 2
                 <LF_KEYF3>   TYPE ANY,             "Key field 3
                 <LF_TTARGET> TYPE ANY.             "Text target in call program
  DATA: LW_FIELD_ST   TYPE STRING.

*----------------------------------------------------*
* Init
  LS_FIELD = LPS_FIELD.

* Get field reference in called program
  SPLIT LS_FIELD-FIELDNAME AT '-' INTO LW_FIELD_ST LW_PG_FIELD.
  CHECK LW_PG_FIELD IS NOT INITIAL.
  ASSIGN COMPONENT LW_PG_FIELD OF STRUCTURE <FS_STRUCT> TO <LF_FIELD>.
  CHECK SY-SUBRC IS INITIAL.

*  IF LW_PG_FIELD = 'BIZ_CITYNO'.
*    BREAK QUANGVN.
*  ENDIF.

* Set init value for field
  IF LPW_INITIAL = GC_XMARK.
*   Set init value for screen field
    PERFORM INIT_SET_VALUE_FOR_FIELD
      USING LPS_FIELD
    CHANGING <LF_FIELD>.

*   Set label text of field if need
    PERFORM INIT_SET_LABEL_TEXT USING LPS_FIELD <LF_FIELD>.
  ENDIF.

* Clear description, and check required field
  IF <LF_FIELD> IS INITIAL
  OR <LF_FIELD> = ''.
*   Clear description value
    PERFORM CLEAR_DESC_VALUE USING LS_FIELD.

*   Check field is required
    IF LS_FIELD-CHECK_INIT = 'X'
    AND LPW_NO_CHECK IS INITIAL.
*     if field need check
      READ TABLE LPT_CHKSTEP TRANSPORTING NO FIELDS
        WITH KEY CSTEP = LS_FIELD-CSTEP.
      IF SY-SUBRC IS INITIAL
      OR LPT_CHKSTEP[] IS INITIAL.
        PERFORM SCROLL_TABCONTROL_TO_ERR
          USING LS_FIELD
                1.
        IF I_WARN_REQUIRED IS INITIAL.
*         Set message required for field
          PERFORM SET_FIELD_MSG_REQUIRED
            USING LS_FIELD
                  <LF_FIELD>
                  LPW_ROW.
        ELSE.
*         Set message required for field
          PERFORM SET_FIELD_MSG_REQUIRED_W
            USING LS_FIELD
                  <LF_FIELD>
                  LPW_ROW.
        ENDIF.
*       Quit check
        RETURN.
      ENDIF.
    ENDIF.
* Set description, and check input value is valid
  ELSEIF <LF_FIELD> IS NOT INITIAL
     AND LS_FIELD-TABNAME IS NOT INITIAL.
    CLEAR LW_VALID_VAL.
*   Get component name of field in check table
    IF LS_FIELD-KEYF1 IS NOT INITIAL.
      LW_FNAME = LS_FIELD-KEYF1.
    ELSE.
*     Get field type name
      DESCRIBE FIELD <LF_FIELD> HELP-ID LW_FNAME.
*     Get component name in structure
      IF LW_FNAME CS '-'.
        SPLIT LW_FNAME AT '-' INTO LW_FNAME LW_FNAME.
      ENDIF.
    ENDIF.

*   Get parents value in called program
    IF LS_FIELD-PRFIELD2 IS NOT INITIAL.
*     Get Parents field value in called program
      CONCATENATE '(' LPW_REPID ')'  LS_FIELD-PRFIELD2
             INTO LW_PG_FIELD.
      ASSIGN (LW_PG_FIELD) TO <LF_KEYF2>.
    ENDIF.
    IF LS_FIELD-PRFIELD3 IS NOT INITIAL.
*     Get Parents field value in called program
      CONCATENATE '(' LPW_REPID ')' LS_FIELD-PRFIELD3
             INTO LW_PG_FIELD.
      ASSIGN (LW_PG_FIELD) TO <LF_KEYF3>.
    ENDIF.

*   Retrieve data using: Local check table in called program
    CONCATENATE '(' LPW_REPID ')' LS_FIELD-TABNAME
           INTO LW_CTABNM.
    ASSIGN (LW_CTABNM) TO <LFT_CTAB>.
    IF SY-SUBRC IS INITIAL.
      IF  <LF_KEYF2> IS ASSIGNED AND <LF_KEYF2> IS NOT INITIAL
      AND <LF_KEYF3> IS ASSIGNED AND <LF_KEYF3> IS NOT INITIAL.
*       Search data from local check table
        READ TABLE <LFT_CTAB> ASSIGNING <LF_RECORD>
          WITH KEY (LW_FNAME)       = <LF_FIELD>
                   (LS_FIELD-KEYF2) = <LF_KEYF2>
                   (LS_FIELD-KEYF3) = <LF_KEYF3>.
      ELSEIF <LF_KEYF2> IS ASSIGNED AND <LF_KEYF2> IS NOT INITIAL.
*       Search data from local check table
        READ TABLE <LFT_CTAB> ASSIGNING <LF_RECORD>
          WITH KEY (LW_FNAME)       = <LF_FIELD>
                   (LS_FIELD-KEYF2) = <LF_KEYF2>.
      ELSE.
*       Search data from local check table
        READ TABLE <LFT_CTAB> ASSIGNING <LF_RECORD>
          WITH KEY (LW_FNAME)       = <LF_FIELD>.
      ENDIF.

*     Set flag: value of field is valid and set description
      IF SY-SUBRC IS INITIAL.
        LW_VALID_VAL = GC_XMARK.
        PERFORM SET_DESC_VALUE USING LS_FIELD <LF_RECORD>.
      ENDIF.
*--------------------------------------------------------------------*
*   Retrieve data using: DB table
    ELSE.
*     Build where clause: [Fieldname] = [Fieldvalue]
      CONCATENATE LW_FNAME ' = ''' <LF_FIELD> '''' INTO LW_WHERE.
*     Build where clause: [KeyF2] = [KeyF2Value]
      IF <LF_KEYF2> IS ASSIGNED AND <LF_KEYF2> IS NOT INITIAL.
        CONCATENATE LW_WHERE ' AND '
                    LS_FIELD-KEYF2 ' = ''' <LF_KEYF2> ''''
               INTO LW_WHERE.
      ENDIF.
*     Build where clause: [KeyF3] = [KeyF3Value]
      IF <LF_KEYF3> IS ASSIGNED AND <LF_KEYF3> IS NOT INITIAL.
        CONCATENATE LW_WHERE ' AND '
                    LS_FIELD-KEYF3 ' = ''' <LF_KEYF3> ''''
               INTO LW_WHERE.
      ENDIF.

*     Get field name in called program
      CONCATENATE '(' LPW_REPID ')' LS_FIELD-TEXT_TARGET
             INTO LW_PG_FIELD.
*     Get field value
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
      IF SY-SUBRC IS INITIAL.
        LW_VALID_VAL = GC_XMARK.
      ENDIF.
    ENDIF.

    IF LW_VALID_VAL IS INITIAL.
*     Clear description value
      PERFORM CLEAR_DESC_VALUE USING LS_FIELD.

*     Get message for invalid field:
      IF LPW_NO_CHECK IS INITIAL.
        PERFORM SCROLL_TABCONTROL_TO_ERR
          USING LS_FIELD
                1.
*       Set message invalid for field
        PERFORM SET_FIELD_MSG_INVALID
          USING LS_FIELD
                <LF_FIELD>
                LPW_ROW.
*       Quit check
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

  IF LPW_NO_CHECK IS INITIAL AND
     LS_FIELD-CKSUBR IS NOT INITIAL.
*   Set check row before call check subroutine
    GW_CURR_CHECKROW  = LPW_ROW.
    PERFORM (LS_FIELD-CKSUBR) IN PROGRAM (LPW_REPID) IF FOUND.
  ENDIF.
ENDFORM.                    " PAI_PROCESS_EACH_FIELD

*&---------------------------------------------------------------------*
*&      Form  PAI_PROCESS_FIELD_TABCONTROL
*&---------------------------------------------------------------------*
*       Process each field on table control
*----------------------------------------------------------------------*
*       -->  LPS_FIELD        Field info
*       -->  LPT_FIELD_LOOP   Field list on table controls
*       -->  LPW_INITIAL      Initial flag
*       -->  LPW_NO_CHECK     No check data
*----------------------------------------------------------------------*
FORM PAI_PROCESS_FIELD_TABCONTROL
  USING LPS_FIELD       TYPE ZTB_FIELD_DB
        LPT_FIELD_LOOP  TYPE ZTT_FIELD_DB
        LPW_INITIAL     TYPE XMARK
        LPW_NO_CHECK    TYPE XMARK
        I_WARN_REQUIRED TYPE XMARK
        LPT_CHKSTEP     TYPE ZTT_SCR_CHKSTEP
        I_CONFIG_PROG   TYPE SY-REPID
        I_DYNNR         TYPE SY-DYNNR.

  DATA:
    LS_FIELD_LOOP TYPE ZTB_FIELD_DB,    "Field info need check value
    LW_PG_FIELD   TYPE CHAR100,         "Program field:([PgName])FName
    LW_LOOPSTR    TYPE TABNM,           "Loop Structure name
    LW_ROW        TYPE I,
    LT_CHKSTEP    TYPE ZTT_SCR_CHKSTEP,
    LW_FNAME      TYPE FIELDNAME.       "Field name

  FIELD-SYMBOLS:
    <LFT_LOOPTAB> TYPE STANDARD TABLE,  "Loop table of table control
    <LF_LOOPSTR>  TYPE ANY.             "Loop structure of table control

* Get loop table of table control in called program
  CONCATENATE '(' LPS_FIELD-REPID ')' LPS_FIELD-LOOPTAB
         INTO LW_PG_FIELD.
  ASSIGN (LW_PG_FIELD) TO <LFT_LOOPTAB>.
  CHECK SY-SUBRC IS INITIAL.

* Get loop structure of table control in called program
  SPLIT LPS_FIELD-FIELDNAME AT '-' INTO LW_LOOPSTR LW_FNAME.

  CONCATENATE '(' LPS_FIELD-REPID ')' LW_LOOPSTR
         INTO LW_PG_FIELD.

  ASSIGN (LW_PG_FIELD) TO <LF_LOOPSTR>.
  CHECK SY-SUBRC IS INITIAL.

* Loop table to structure design in prog to process right row
  LOOP AT <LFT_LOOPTAB> INTO <LF_LOOPSTR>.
*   Row in table
    LW_ROW = SY-TABIX.

    CLEAR: LT_CHKSTEP.
*   Prepare check steps
    PERFORM PREPARE_PROG_STEP
      USING I_CONFIG_PROG
            I_DYNNR
   CHANGING LT_CHKSTEP.

*   Process all field of structure on current table control
    LOOP AT LPT_FIELD_LOOP INTO LS_FIELD_LOOP
      WHERE LOOPTAB = LPS_FIELD-LOOPTAB.
*     Process each field on screen
      PERFORM PAI_PROCESS_EACH_FIELD
        USING LS_FIELD_LOOP
              LPW_INITIAL
              LPW_NO_CHECK
              I_WARN_REQUIRED
              LW_ROW
              LT_CHKSTEP."LPT_CHKSTEP.
    ENDLOOP.
    MODIFY <LFT_LOOPTAB> FROM <LF_LOOPSTR> INDEX LW_ROW.
  ENDLOOP.

ENDFORM.                    " PAI_PROCESS_FIELD_TABCONTROL
*&---------------------------------------------------------------------*
*&      Form  PAI_SCR_PROCESS_FIELD_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_FIELD        text
*      -->LPT_FIELD_LOOP   text
*      -->LPW_INITIAL      text
*      -->LPW_NO_CHECK     text
*      -->LPT_CHKSTEP      text
*      -->I_WARN_REQUIRED  text
*      -->LPW_REPID_DATA   text
*----------------------------------------------------------------------*
FORM PAI_SCR_PROCESS_FIELD_TAB  USING LPS_FIELD       TYPE ZTB_FIELD_DB
                                      LPT_FIELD_LOOP  TYPE ZTT_FIELD_DB
                                      LPW_INITIAL     TYPE XMARK
                                      LPW_NO_CHECK    TYPE XMARK
                                    LPT_CHKSTEP     TYPE ZTT_SCR_CHKSTEP
                                    I_WARN_REQUIRED TYPE XMARK
                                    LPW_REPID_DATA  TYPE SY-CPROG.
  DATA: LS_FIELD_LOOP TYPE ZTB_FIELD_DB,    "Field info need check value
        LW_PG_FIELD   TYPE CHAR100,         "Program field:([PgName])FName
        LW_LOOPSTR    TYPE TABNM,           "Loop Structure name
        LW_ROW        TYPE I,
        LW_FNAME      TYPE FIELDNAME.       "Field name

  FIELD-SYMBOLS: <LFT_LOOPTAB> TYPE STANDARD TABLE,
                 "Loop table of table control
                 <LF_LOOPSTR>  TYPE ANY.             "Loop structure of table control

*----------------------------------------------------*
* Get loop table of table control in called program
  CONCATENATE '(' LPW_REPID_DATA ')' LPS_FIELD-LOOPTAB
         INTO LW_PG_FIELD.
  ASSIGN (LW_PG_FIELD) TO <LFT_LOOPTAB>.
  CHECK SY-SUBRC IS INITIAL.

* Get loop structure of table control in called program
  SPLIT LPS_FIELD-FIELDNAME AT '-' INTO LW_LOOPSTR LW_FNAME.

  CONCATENATE '(' LPW_REPID_DATA ')' LW_LOOPSTR
         INTO LW_PG_FIELD.

  ASSIGN (LW_PG_FIELD) TO <LF_LOOPSTR>.
  CHECK SY-SUBRC IS INITIAL.

* Loop table to structure design in prog to process right row
  LOOP AT <LFT_LOOPTAB> INTO <LF_LOOPSTR>.
*   Row in table
    LW_ROW = SY-TABIX.

*   Process all field of structure on current table control
    LOOP AT LPT_FIELD_LOOP INTO LS_FIELD_LOOP
      WHERE LOOPTAB = LPS_FIELD-LOOPTAB.
*     Process each field on screen
      PERFORM PAI_PROCESS_EACH_FIELD_SCR USING  LS_FIELD_LOOP
                                                LPW_INITIAL
                                                LPW_NO_CHECK
                                                I_WARN_REQUIRED
                                                LW_ROW
                                                LPT_CHKSTEP
                                                LPW_REPID_DATA.
    ENDLOOP.
    MODIFY <LFT_LOOPTAB> FROM <LF_LOOPSTR> INDEX LW_ROW.
  ENDLOOP.
ENDFORM.                    " PAI_PROCESS_FIELD_TABCONTROL
*&---------------------------------------------------------------------*
*&      Form  PREPARE_FIELD_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPT_FIELD       All field info
*      <--LPT_FIELD_LOOP  Field info in table control
*----------------------------------------------------------------------*
FORM PREPARE_FIELD_LIST
  CHANGING LPT_FIELD      TYPE ZTT_FIELD_DB
           LPT_FIELD_LOOP TYPE ZTT_FIELD_DB.
  DATA:
    LT_FIELD_TMP_LOOP  TYPE ZTT_FIELD_DB.

* Get field list to process
  LPT_FIELD_LOOP = LPT_FIELD.
  DELETE LPT_FIELD WHERE LOOPTAB IS NOT INITIAL.
  DELETE LPT_FIELD_LOOP WHERE LOOPTAB IS INITIAL.

  LT_FIELD_TMP_LOOP = LPT_FIELD_LOOP.
  DELETE ADJACENT DUPLICATES FROM LT_FIELD_TMP_LOOP COMPARING LOOPTAB.
  APPEND LINES OF LT_FIELD_TMP_LOOP TO LPT_FIELD.
  SORT LPT_FIELD BY FPOSI.
ENDFORM.                    " PREPARE_FIELD_LIST

*&---------------------------------------------------------------------*
*&      Form  SCROLL_TABCONTROL_TO_ERR
*&---------------------------------------------------------------------*
*       Scroll table control to error line
*----------------------------------------------------------------------*
*      -->LPW_TABCONTROL  Table control
*      -->LPW_ROW         Error line
*----------------------------------------------------------------------*
FORM SCROLL_TABCONTROL_TO_ERR
  USING    LPS_FIELD TYPE ZTB_FIELD_DB
           LPW_ROW   TYPE I.
  DATA:
    LW_PG_FIELD   TYPE CHAR100.         "Program field: ([PgName])FName
  FIELD-SYMBOLS:
    <LF_TABCONTROL> TYPE ANY,
    <LF_TOPLINE>    TYPE I.

  CONCATENATE '(' LPS_FIELD-REPID ')' LPS_FIELD-TABCONTROL
         INTO LW_PG_FIELD.
  ASSIGN (LW_PG_FIELD) TO <LF_TABCONTROL>.
*  ASSIGN (LW_PG_FIELD) TO <LF_TOPLINE>.
  IF SY-SUBRC IS INITIAL.

    ASSIGN COMPONENT 'TOP_LINE' OF STRUCTURE <LF_TABCONTROL>
      TO <LF_TOPLINE>.
    IF SY-SUBRC IS INITIAL.
      <LF_TOPLINE> = LPW_ROW.
*      LPW_ROW      = 1.
    ENDIF.
  ENDIF.

ENDFORM.                    " SCROLL_TABCONTROL_TO_ERR

*&---------------------------------------------------------------------*
*&      Form  INIT_SET_VALUE_FOR_FIELD
*&---------------------------------------------------------------------*
*       Set init value for screen field
*----------------------------------------------------------------------*
*      -->LPS_FIELD  Field info
*----------------------------------------------------------------------*
FORM INIT_SET_VALUE_FOR_FIELD
  USING    LPS_FIELD    TYPE ZTB_FIELD_DB
  CHANGING LPS_FIELDVL  TYPE ANY.
  DATA:
*   Prog initfield: ([PgName])FName
    LW_INIT_FIELD TYPE CHAR100.
  FIELD-SYMBOLS:
    <LF_FIELD>    TYPE ANY,             "Field value
    <LF_INIT_FLD> TYPE ANY.             "Init value field in call prog

  IF LPS_FIELD-INIT_FIELD IS NOT INITIAL.
*   If first char is ',
    IF LPS_FIELD-INIT_FIELD(1) = ''''.
*     Assign init value from INIT_FIELD
*      <LF_FIELD> = LPS_FIELD-INIT_FIELD+1.
      LPS_FIELDVL = LPS_FIELD-INIT_FIELD+1.
*   Get init value from call program
    ELSE.
*     Get init value field in called program
      CONCATENATE '(' LPS_FIELD-REPID ')' LPS_FIELD-INIT_FIELD
             INTO LW_INIT_FIELD.
      ASSIGN (LW_INIT_FIELD) TO <LF_INIT_FLD>.
      IF SY-SUBRC IS INITIAL.
*       Assign init value from field in called program
*        <LF_FIELD> = <LF_INIT_FLD>.
        LPS_FIELDVL = <LF_INIT_FLD>.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " INIT_SET_VALUE_FOR_FIELD
*&---------------------------------------------------------------------*
*&      Form  INIT_SET_LABEL_TEXT
*&---------------------------------------------------------------------*
*       Set label text of field if need
*----------------------------------------------------------------------*
*      -->LPS_FIELD  Field info
*----------------------------------------------------------------------*
FORM INIT_SET_LABEL_TEXT
  USING    LPS_FIELD    TYPE ZTB_FIELD_DB
           LPS_FIELDVL  TYPE ANY.
  DATA:
*   Prog initfield: ([PgName])FName
    LW_LABEL_FIELD TYPE CHAR100,
    LW_SCRTEXT_L   TYPE SCRTEXT_L.
  FIELD-SYMBOLS:
    <LF_FIELD>   TYPE ANY,             "Field value
    <LF_LBL_FLD> TYPE ANY.             "Label field in call prog

  IF LPS_FIELD-LABELF IS NOT INITIAL.
*   Get Label field in called program
    CONCATENATE '(' LPS_FIELD-REPID ')' LPS_FIELD-LABELF
           INTO LW_LABEL_FIELD.
    ASSIGN (LW_LABEL_FIELD) TO <LF_LBL_FLD>.
    IF SY-SUBRC IS INITIAL AND <LF_LBL_FLD> IS INITIAL.
*     Get label text
      CALL FUNCTION 'ZFM_SCR_GET_FIELD_LABEL'
        EXPORTING
          I_FIELDNAME = LPS_FIELD-FIELDNAME
          I_FIELD     = LPS_FIELDVL
        IMPORTING
          E_SCRTEXT_L = LW_SCRTEXT_L.
      <LF_LBL_FLD> = LW_SCRTEXT_L.
    ENDIF.
  ENDIF.

ENDFORM.                    " INIT_SET_LABEL_TEXT

*&---------------------------------------------------------------------*
*&      Form  PREPARE_PROG_STEP
*&---------------------------------------------------------------------*
*       Prepare progam step
*----------------------------------------------------------------------*
*      -->LPW_CSTEP         Single check step
*      -->LPW_CONFIG_PROG   Program
*      <--LPT_SCR_CHKSTEP   List of check step
*----------------------------------------------------------------------*
FORM PREPARE_PROG_STEP
  USING    LPW_PROG         TYPE SY-REPID
           LPW_DYNNR        TYPE SY-DYNNR
  CHANGING LPT_SCR_CHKSTEP  TYPE ZTT_SCR_CHKSTEP.

  DATA:
    LS_PROG_STEP TYPE ZTB_PROG_STEP,
    LW_EQUAL     TYPE XMARK.

  READ TABLE GT_PROG_STEP TRANSPORTING NO FIELDS
    WITH KEY REPID = LPW_PROG.
  IF SY-SUBRC IS NOT INITIAL.
    SELECT *
      INTO TABLE GT_PROG_STEP
      FROM ZTB_PROG_STEP
     WHERE REPID = LPW_PROG.
  ENDIF.

  LOOP AT GT_PROG_STEP INTO LS_PROG_STEP." WHERE DYNNR = LPW_DYNNR.
    PERFORM COMPARE
      USING LS_PROG_STEP-REPID
            LS_PROG_STEP-FIELD1
            LS_PROG_STEP-VALUE1
   CHANGING LW_EQUAL.
    IF LW_EQUAL IS INITIAL.
      CONTINUE.
    ENDIF.

    PERFORM COMPARE
      USING LS_PROG_STEP-REPID
            LS_PROG_STEP-FIELD2
            LS_PROG_STEP-VALUE2
   CHANGING LW_EQUAL.
    IF LW_EQUAL IS INITIAL.
      CONTINUE.
    ENDIF.

    PERFORM COMPARE
      USING LS_PROG_STEP-REPID
            LS_PROG_STEP-FIELD3
            LS_PROG_STEP-VALUE3
   CHANGING LW_EQUAL.
    IF LW_EQUAL IS INITIAL.
      CONTINUE.
    ENDIF.
    APPEND LS_PROG_STEP-CSTEP TO LPT_SCR_CHKSTEP.
  ENDLOOP.

*  IF LPT_SCR_CHKSTEP[] IS NOT INITIAL.
*    APPEND INITIAL LINE TO LPT_SCR_CHKSTEP.
*  ENDIF.
  APPEND INITIAL LINE TO LPT_SCR_CHKSTEP.
  SORT LPT_SCR_CHKSTEP BY CSTEP.
  DELETE ADJACENT DUPLICATES FROM LPT_SCR_CHKSTEP COMPARING CSTEP.
ENDFORM.                    " PREPARE_PROG_STEP
*&---------------------------------------------------------------------*
*&      Form  PREPARE_PROG_STEP_SCR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_PROG         text
*      -->LPW_PROG_DATA    text
*      -->LPW_DYNNR        text
*      -->LPT_SCR_CHKSTEP  text
*----------------------------------------------------------------------*
FORM PREPARE_PROG_STEP_SCR USING    LPW_PROG         TYPE SY-REPID
                                    LPW_PROG_DATA    TYPE SY-REPID
                                    LPW_DYNNR        TYPE SY-DYNNR
                         CHANGING LPT_SCR_CHKSTEP  TYPE ZTT_SCR_CHKSTEP.
  DATA: LS_PROG_STEP TYPE ZTB_PROG_STEP,
        LW_EQUAL     TYPE XMARK.

*----------------------------------------------------*
  READ TABLE GT_PROG_STEP TRANSPORTING NO FIELDS WITH KEY
       REPID = LPW_PROG.
  IF SY-SUBRC IS NOT INITIAL.
    SELECT *
      INTO TABLE GT_PROG_STEP
      FROM ZTB_PROG_STEP
     WHERE REPID = LPW_PROG.
  ENDIF.

  LOOP AT GT_PROG_STEP INTO LS_PROG_STEP WHERE DYNNR = LPW_DYNNR.
    PERFORM COMPARE_SCR
      USING LPW_PROG_DATA
            LS_PROG_STEP-REPID
            LS_PROG_STEP-FIELD1
            LS_PROG_STEP-VALUE1
   CHANGING LW_EQUAL.
    IF LW_EQUAL IS INITIAL.
      CONTINUE.
    ENDIF.

    PERFORM COMPARE_SCR
      USING LPW_PROG_DATA
            LS_PROG_STEP-REPID
            LS_PROG_STEP-FIELD2
            LS_PROG_STEP-VALUE2
   CHANGING LW_EQUAL.
    IF LW_EQUAL IS INITIAL.
      CONTINUE.
    ENDIF.

    PERFORM COMPARE_SCR
      USING LPW_PROG_DATA
            LS_PROG_STEP-REPID
            LS_PROG_STEP-FIELD3
            LS_PROG_STEP-VALUE3
   CHANGING LW_EQUAL.
    IF LW_EQUAL IS INITIAL.
      CONTINUE.
    ENDIF.
    APPEND LS_PROG_STEP-CSTEP TO LPT_SCR_CHKSTEP.
  ENDLOOP.

  IF LPT_SCR_CHKSTEP[] IS NOT INITIAL.
    APPEND INITIAL LINE TO LPT_SCR_CHKSTEP.
  ENDIF.
  SORT LPT_SCR_CHKSTEP BY CSTEP.
  DELETE ADJACENT DUPLICATES FROM LPT_SCR_CHKSTEP COMPARING CSTEP.
ENDFORM.                    " PREPARE_PROG_STEP
*&---------------------------------------------------------------------*
*&      Form  COMPARE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_REPID  Program
*      -->LPW_FIELD  Condition Field
*      -->LPW_VALUE  Condition value
*      <--LPW_EQUAL  Equal flag
*----------------------------------------------------------------------*
FORM COMPARE
  USING    LPW_REPID     TYPE ZTB_PROG_STEP-REPID
           LPW_FIELD     TYPE ZTB_PROG_STEP-FIELD1
           LPW_VALUE     TYPE ZTB_PROG_STEP-VALUE1
  CHANGING LPW_EQUAL     TYPE XMARK.

  DATA:
    LW_PROG_FIELD   TYPE CHAR100.
  FIELD-SYMBOLS:
    <LF_COND_FIELD> TYPE ANY,             "Condition Field
    <LF_COND_VALUE> TYPE ANY.             "Condition value

* Init
  CLEAR LPW_EQUAL.
  UNASSIGN: <LF_COND_FIELD>, <LF_COND_VALUE>.

  IF LPW_FIELD IS INITIAL AND LPW_VALUE IS INITIAL.
    LPW_EQUAL = GC_XMARK.
    RETURN.
  ENDIF.

* Get Condition field in called program
  CONCATENATE '(' LPW_REPID ')' LPW_FIELD
         INTO LW_PROG_FIELD.
  ASSIGN (LW_PROG_FIELD) TO <LF_COND_FIELD>.
  CHECK SY-SUBRC IS INITIAL.
  IF LPW_VALUE IS INITIAL.
    IF <LF_COND_FIELD> IS INITIAL.
      LPW_EQUAL = GC_XMARK.
    ENDIF.
  ELSEIF LPW_VALUE(1) = ''''.
    IF LPW_VALUE+1(1) = '!'.
      IF <LF_COND_FIELD> <> LPW_VALUE+2.
        LPW_EQUAL = GC_XMARK.
      ENDIF.
    ELSEIF <LF_COND_FIELD> = LPW_VALUE+1.
      LPW_EQUAL = GC_XMARK.
    ENDIF.
  ELSE.
    IF LPW_VALUE(1) = '!'.
*     Get Condition value in called program
      CONCATENATE '(' LPW_REPID ')' LPW_VALUE+1
             INTO LW_PROG_FIELD.
      ASSIGN (LW_PROG_FIELD) TO <LF_COND_VALUE>.
      CHECK SY-SUBRC IS INITIAL.
      IF <LF_COND_FIELD> <> <LF_COND_VALUE>.
        LPW_EQUAL = GC_XMARK.
      ENDIF.
    ELSE.
*     Get Condition value in called program
      CONCATENATE '(' LPW_REPID ')' LPW_VALUE
             INTO LW_PROG_FIELD.
      ASSIGN (LW_PROG_FIELD) TO <LF_COND_VALUE>.
      CHECK SY-SUBRC IS INITIAL.
      IF <LF_COND_FIELD> = <LF_COND_VALUE>.
        LPW_EQUAL = GC_XMARK.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " COMPARE
*&---------------------------------------------------------------------*
*&      Form  COMPARE_SCR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_REPID_DATA  text
*      -->LPW_REPID       text
*      -->LPW_FIELD       text
*      -->LPW_VALUE       text
*      -->LPW_EQUAL       text
*----------------------------------------------------------------------*
FORM COMPARE_SCR USING    LPW_REPID_DATA  TYPE ZTB_PROG_STEP-REPID
                          LPW_REPID       TYPE ZTB_PROG_STEP-REPID
                          LPW_FIELD       TYPE ZTB_PROG_STEP-FIELD1
                          LPW_VALUE       TYPE ZTB_PROG_STEP-VALUE1
                 CHANGING LPW_EQUAL       TYPE XMARK.
  DATA: LW_PROG_FIELD   TYPE CHAR100.
  FIELD-SYMBOLS: <LF_COND_FIELD> TYPE ANY,             "Condition Field
                 <LF_COND_VALUE> TYPE ANY.             "Condition value

*----------------------------------------------------*
* Init
  CLEAR LPW_EQUAL.
  UNASSIGN: <LF_COND_FIELD>, <LF_COND_VALUE>.

  IF LPW_FIELD IS INITIAL AND LPW_VALUE IS INITIAL.
    LPW_EQUAL = GC_XMARK.
    RETURN.
  ENDIF.

* Get Condition field in called program
  CONCATENATE '(' LPW_REPID_DATA ')' LPW_FIELD
         INTO LW_PROG_FIELD.
  ASSIGN (LW_PROG_FIELD) TO <LF_COND_FIELD>.
  CHECK SY-SUBRC IS INITIAL.
  IF LPW_VALUE IS INITIAL.
    IF <LF_COND_FIELD> IS INITIAL.
      LPW_EQUAL = GC_XMARK.
    ENDIF.
  ELSEIF LPW_VALUE(1) = ''''.
    IF <LF_COND_FIELD> = LPW_VALUE+1.
      LPW_EQUAL = GC_XMARK.
    ENDIF.
  ELSE.
*   Get Condition value in called program
    CONCATENATE '(' LPW_REPID_DATA ')' LPW_VALUE
           INTO LW_PROG_FIELD.
    ASSIGN (LW_PROG_FIELD) TO <LF_COND_VALUE>.
    CHECK SY-SUBRC IS INITIAL.

    IF <LF_COND_FIELD> = <LF_COND_VALUE>.
      LPW_EQUAL = GC_XMARK.
    ENDIF.
  ENDIF.
ENDFORM.                    " COMPARE
*&---------------------------------------------------------------------*
*&      Form  PREPARE_FIELD_STATUS
*&---------------------------------------------------------------------*
*       Prepare field status
*----------------------------------------------------------------------*
*      -->LPW_CPROG         Call program
*      -->LPW_CONFIG_PROG   Config program
*----------------------------------------------------------------------*
FORM PREPARE_FIELD_STATUS USING    LPW_CPROG        TYPE SY-REPID
                          CHANGING LPW_CONFIG_PROG  TYPE SY-REPID.
  DATA: LT_FIELD_DB   TYPE TABLE OF ZTB_FIELD_DB,
        LT_FIELD_DESC TYPE TABLE OF ZTB_FIELD_DESC,
        LS_FIELD_DB   TYPE ZTB_FIELD_DB,
        LS_FIELD_DESC TYPE ZTB_FIELD_DESC.

*----------------------------------------------------*
  IF LPW_CONFIG_PROG IS INITIAL.
    LPW_CONFIG_PROG = LPW_CPROG.
  ENDIF.
  LS_FIELD_DB-REPID   = LPW_CPROG.
  LS_FIELD_DESC-REPID = LPW_CPROG.

  READ TABLE GT_FIELD_DB TRANSPORTING NO FIELDS
    WITH KEY REPID = LPW_CONFIG_PROG.
  IF SY-SUBRC IS NOT INITIAL.
*   Get field status from DB
    SELECT *
      INTO TABLE LT_FIELD_DB
      FROM ZTB_FIELD_DB
     WHERE REPID = LPW_CONFIG_PROG.

*   Get field description from DB
    SELECT *
      INTO TABLE LT_FIELD_DESC
      FROM ZTB_FIELD_DESC
     WHERE REPID = LPW_CONFIG_PROG.

*   Replace config prog by prog
    IF LPW_CONFIG_PROG <> LPW_CPROG.
      MODIFY LT_FIELD_DB FROM LS_FIELD_DB TRANSPORTING REPID
        WHERE REPID = LPW_CONFIG_PROG.
      MODIFY LT_FIELD_DESC FROM LS_FIELD_DESC TRANSPORTING REPID
        WHERE REPID = LPW_CONFIG_PROG.
    ENDIF.

    APPEND LINES OF LT_FIELD_DB TO GT_FIELD_DB.
    APPEND LINES OF LT_FIELD_DESC TO GT_FIELD_DESC.
    SORT GT_FIELD_DB BY REPID DYNNR FPOSI.
    SORT GT_FIELD_DESC BY REPID DYNNR FIELDNAME FPOSI.
  ENDIF.
ENDFORM.                    " PREPARE_FIELD_STATUS
*&---------------------------------------------------------------------*
*&      Form  PREPARE_FIELD_STATUS_ROLE
*&---------------------------------------------------------------------*
*       Prepare field status
*----------------------------------------------------------------------*
*      -->LPW_CPROG         Call program
*      -->LPW_CONFIG_PROG   Config program
*----------------------------------------------------------------------*
FORM PREPARE_FIELD_STATUS_ROLE
  USING    LPW_CPROG        TYPE SY-REPID
  CHANGING LPW_CONFIG_PROG  TYPE SY-REPID.

  DATA:
    LS_ROLE_FLD TYPE ZST_BM_ROLE_FLD,
    LT_ROLE_FLD TYPE TABLE OF ZST_BM_ROLE_FLD,
    LS_USR_ROLE TYPE ZTB_BM_USR_ROLE,
    LT_FIELDCAT TYPE LVC_T_FCAT,
    LS_FIELDCAT TYPE LVC_S_FCAT.
  FIELD-SYMBOLS:
    <LF_ROLE_FLD>       TYPE ZST_BM_ROLE_FLD.

  IF GT_USR_ROLE[] IS INITIAL.
    SELECT *
      FROM ZTB_BM_USR_ROLE
      INTO TABLE GT_USR_ROLE
     WHERE BNAME = SY-UNAME.
  ENDIF.

  IF LPW_CONFIG_PROG IS INITIAL.
    LPW_CONFIG_PROG   = LPW_CPROG.
  ENDIF.
  LS_ROLE_FLD-REPID   = LPW_CPROG.

  READ TABLE GT_ROLE_FLD TRANSPORTING NO FIELDS
    WITH KEY REPID = LPW_CONFIG_PROG.
  IF SY-SUBRC IS NOT INITIAL
  AND GT_USR_ROLE[] IS NOT INITIAL.
*   Get field status from DB
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE LT_ROLE_FLD
      FROM ZTB_BM_ROLE_FLD
       FOR ALL ENTRIES IN GT_USR_ROLE
     WHERE REPID  = LPW_CONFIG_PROG
       AND BMROLE = GT_USR_ROLE-BMROLE.

*   Replace config prog by prog
    IF LPW_CONFIG_PROG <> LPW_CPROG.
      MODIFY LT_ROLE_FLD FROM LS_ROLE_FLD TRANSPORTING REPID
        WHERE REPID = LPW_CONFIG_PROG.
    ENDIF.

    LOOP AT LT_ROLE_FLD ASSIGNING <LF_ROLE_FLD>.
      IF <LF_ROLE_FLD>-STRUC IS NOT INITIAL.
        CLEAR: LT_FIELDCAT[].
        CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
          EXPORTING
            I_STRUCTURE_NAME       = <LF_ROLE_FLD>-FIELDNAME
            I_INTERNAL_TABNAME     = <LF_ROLE_FLD>-FIELDNAME
          CHANGING
            CT_FIELDCAT            = LT_FIELDCAT
          EXCEPTIONS
            INCONSISTENT_INTERFACE = 1
            PROGRAM_ERROR          = 2
            OTHERS                 = 3.
        IF SY-SUBRC IS INITIAL.
          LOOP AT LT_FIELDCAT INTO LS_FIELDCAT.
            CONCATENATE <LF_ROLE_FLD>-TABNM
                        LS_FIELDCAT-FIELDNAME
                   INTO <LF_ROLE_FLD>-FULLFIELD SEPARATED BY '-'.
            APPEND <LF_ROLE_FLD> TO GT_ROLE_FLD.
          ENDLOOP.
        ENDIF.
      ELSE.
        CONCATENATE <LF_ROLE_FLD>-TABNM
                    <LF_ROLE_FLD>-FIELDNAME
               INTO <LF_ROLE_FLD>-FULLFIELD SEPARATED BY '-'.
        APPEND <LF_ROLE_FLD> TO GT_ROLE_FLD.
      ENDIF.
    ENDLOOP.

    SORT GT_ROLE_FLD BY REPID FULLFIELD.
  ENDIF.
ENDFORM.                    " PREPARE_FIELD_STATUS_ROLE

*&---------------------------------------------------------------------*
*&      Form  CLEAR_INACTIVE_ELEMENT
*&---------------------------------------------------------------------*
*       Clear inactive element
*----------------------------------------------------------------------*
*      -->LPS_FIELD_DB  Field status
*----------------------------------------------------------------------*
FORM CLEAR_INACTIVE
  USING    LPS_FIELD_DB   TYPE ZTB_FIELD_DB.
  DATA:
    LW_PG_FIELD       TYPE CHAR100.
  FIELD-SYMBOLS:
    <LF_FIELD>        TYPE ANY.

  CONCATENATE '(' LPS_FIELD_DB-REPID ')' LPS_FIELD_DB-FIELDNAME
         INTO LW_PG_FIELD.
  ASSIGN (LW_PG_FIELD) TO <LF_FIELD>.
  IF SY-SUBRC IS INITIAL.
    CLEAR: <LF_FIELD>.
  ENDIF.
ENDFORM.                    " CLEAR_INACTIVE
*&---------------------------------------------------------------------*
*&      Form  CONVERT_ALPHA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MSGV1  text
*      <--P_LW_TEXT  text
*----------------------------------------------------------------------*
FORM CONVERT_ALPHA  USING    LPW_MSGV1  TYPE ANY
                    CHANGING LPW_TEXT   TYPE SYMSGV.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = LPW_MSGV1
    IMPORTING
      OUTPUT = LPW_TEXT.
ENDFORM.                    " CONVERT_ALPHA

*&---------------------------------------------------------------------*
*&      Form  SET_LIST_BOX_VALUE
*&---------------------------------------------------------------------*
*       Set list box value
*----------------------------------------------------------------------*
*      -->P_LS_FIELD  text
*----------------------------------------------------------------------*
FORM SET_LIST_BOX_VALUE
  USING LPS_FIELD     TYPE ZTB_FIELD_DB
        LPW_SET_INIT  TYPE XMARK
        LPW_DIS_LBOX  TYPE XMARK.

  DATA:
    LW_FNAME         TYPE FIELDNAME,   "Field name
    LW_CTABNM        TYPE CHAR100,     "Program field: ([PgName])FName
    LW_PG_FIELD      TYPE CHAR100,     "Program field: ([PgName])FName
    LW_SETLIST_WHERE TYPE STRING,      "Where clause
    LW_VALID_VAL     TYPE XMARK,        "Value of field is valid
    LW_VRM_ID        TYPE VRM_ID,
    LT_LISTBOX       TYPE VRM_VALUES,
    LS_LISTBOX       TYPE VRM_VALUE,
    LW_FOUND         TYPE XMARK.
  FIELD-SYMBOLS:
    <LF_FIELD>   TYPE ANY,             "Field value
    <LF_KEYF2>   TYPE ANY,             "Key field 2
    <LF_KEYF3>   TYPE ANY,             "Key field 3
    <LFT_CTAB>   TYPE ANY TABLE,       "Local check table
    <LF_RECORD>  TYPE ANY,             "Record of field if exist
    <LF_VRM_VAL> TYPE ANY.

  CLEAR: LW_SETLIST_WHERE.
  CONCATENATE '(' LPS_FIELD-REPID ')'  LPS_FIELD-FIELDNAME
         INTO LW_PG_FIELD.
  ASSIGN (LW_PG_FIELD) TO <LF_FIELD>.
*  CLEAR: <LF_FIELD>.

* Get component name of field in check table
  IF LPS_FIELD-KEYF1 IS NOT INITIAL.
    LW_FNAME = LPS_FIELD-KEYF1.
  ENDIF.

* Get parents value in called program
  IF LPS_FIELD-PRFIELD2 IS NOT INITIAL.
*   Get Parents field value in called program
    CONCATENATE '(' LPS_FIELD-REPID ')'  LPS_FIELD-PRFIELD2
           INTO LW_PG_FIELD.
    ASSIGN (LW_PG_FIELD) TO <LF_KEYF2>.
    IF SY-SUBRC IS INITIAL.
      CONCATENATE LPS_FIELD-KEYF2 ' = ''' <LF_KEYF2> ''''
             INTO LW_SETLIST_WHERE.

    ENDIF.
  ENDIF.
  IF LPS_FIELD-PRFIELD3 IS NOT INITIAL.
*   Get Parents field value in called program
    CONCATENATE '(' LPS_FIELD-REPID ')' LPS_FIELD-PRFIELD3
           INTO LW_PG_FIELD.
    ASSIGN (LW_PG_FIELD) TO <LF_KEYF3>.
    IF SY-SUBRC IS INITIAL.
      CONCATENATE LW_SETLIST_WHERE
                  LPS_FIELD-KEYF3
             INTO LW_SETLIST_WHERE SEPARATED BY ' AND '.
      CONCATENATE LW_SETLIST_WHERE ' = ''' <LF_KEYF3> ''''
             INTO LW_SETLIST_WHERE RESPECTING BLANKS.
*      CONCATENATE LW_SETLIST_WHERE ' AND '
*                  LPS_FIELD-KEYF3 ' = ''' <LF_KEYF3> ''''
*             INTO LW_SETLIST_WHERE RESPECTING BLANKS.
    ENDIF.
  ENDIF.

* Retrieve data using: Local check table in called program
  CONCATENATE '(' LPS_FIELD-REPID ')' LPS_FIELD-TABNAME
         INTO LW_CTABNM.
  ASSIGN (LW_CTABNM) TO <LFT_CTAB>.
  IF SY-SUBRC IS INITIAL.
*   Set list value
    IF LPS_FIELD-SETLIST = GC_XMARK.
      LOOP AT <LFT_CTAB> ASSIGNING <LF_RECORD>
        WHERE (LW_SETLIST_WHERE).
        ASSIGN COMPONENT LW_FNAME OF STRUCTURE <LF_RECORD>
          TO <LF_VRM_VAL>.
        IF SY-SUBRC IS INITIAL.
          LS_LISTBOX-KEY = <LF_VRM_VAL>.

          IF <LF_FIELD> IS INITIAL
          AND LPW_SET_INIT = GC_XMARK
          AND SY-TABIX = 1.
            <LF_FIELD> = <LF_VRM_VAL>.
            LW_FOUND   = GC_XMARK.
          ELSEIF <LF_FIELD> = <LF_VRM_VAL>.
            LW_FOUND   = GC_XMARK.
          ENDIF.
        ENDIF.
        ASSIGN COMPONENT LPS_FIELD-TEXT_FIELD OF STRUCTURE <LF_RECORD>
          TO <LF_VRM_VAL>.
        IF SY-SUBRC IS INITIAL.
          LS_LISTBOX-TEXT = <LF_VRM_VAL>.
        ENDIF.
        APPEND LS_LISTBOX TO LT_LISTBOX.
      ENDLOOP.
      LW_VRM_ID = LPS_FIELD-FIELDNAME.
      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          ID     = LW_VRM_ID
          VALUES = LT_LISTBOX.

      IF LPW_DIS_LBOX = GC_XMARK
      AND LINES( LT_LISTBOX ) = 1.
        LOOP AT SCREEN.
          IF SCREEN-NAME = LPS_FIELD-FIELDNAME
          AND SCREEN-ACTIVE = '1'.
            SCREEN-INPUT = '0'.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

  IF LW_FOUND IS INITIAL.
    CLEAR: <LF_FIELD>.
  ENDIF.
ENDFORM.                    " SET_LIST_BOX_VALUE

*&---------------------------------------------------------------------*
*&      Form  9000_SET_TOGGLE_ICON
*&---------------------------------------------------------------------*
*       Set toggle icon
*----------------------------------------------------------------------*
*      -->LPW_TEXT_OFF       Text when off
*      <--LPW_ICONNAME_ON    Frame on
*      <--LPW_ICONNAME_OFF   Frame off
*----------------------------------------------------------------------*
FORM 9000_SET_TOGGLE_ICON
  USING    LPW_TEXT_OFF     TYPE ICON_TEXT
  CHANGING LPW_ICONNAME_ON  TYPE ICON_TEXT
           LPW_ICONNAME_OFF TYPE ICON_TEXT.

* Set icon
  CALL FUNCTION 'ICON_CREATE':
    EXPORTING NAME    = GC_ICON_COLLAPSE
    IMPORTING RESULT  = LPW_ICONNAME_ON,
    EXPORTING NAME    = GC_ICON_EXPAND
              TEXT    = LPW_TEXT_OFF
              INFO    = LPW_TEXT_OFF
    IMPORTING RESULT  = LPW_ICONNAME_OFF.

* Set text off
*  IF LPW_TEXT_OFF IS NOT INITIAL.
*    CONCATENATE LPW_ICONNAME_OFF LPW_TEXT_OFF
*           INTO LPW_ICONNAME_OFF.
*  ENDIF.
ENDFORM.                    " 9000_SET_TOGGLE_ICON

*&---------------------------------------------------------------------*
*&      Form  PBO_MODIFY_TABCONTROL
*&---------------------------------------------------------------------*
*       Modify table control
*----------------------------------------------------------------------*
*      -->LPT_FIELD_DB  Field status
*----------------------------------------------------------------------*
FORM PBO_MODIFY_TABCONTROL
  USING   LPT_FIELD_DB    TYPE ZTT_FIELD_DB
          LPW_DYNNR       TYPE DYNNR
          LPW_MODE        TYPE ZDD_SCR_MODE
          LPW_REPID       TYPE REPID.
  DATA:
    LT_TABCONTROL TYPE TABLE OF ZTB_FIELD_DB,
    LS_TABCONTROL TYPE ZTB_FIELD_DB,
    LT_FIELD_DB   TYPE TABLE OF ZTB_FIELD_DB,
    LS_FIELD_DB   TYPE ZTB_FIELD_DB,
    LW_FNAME_PROG TYPE CHAR61.
  FIELD-SYMBOLS:
    <LF_COLUMN>   TYPE CXTAB_COLUMN,
    <LFT_COLUMNS> TYPE SCXTAB_COLUMN_IT.

  LT_FIELD_DB[]           = LPT_FIELD_DB[].
  DELETE LT_FIELD_DB
    WHERE TABCONTROL IS INITIAL
       OR DYNNR <> LPW_DYNNR AND SUBSCR <> LPW_DYNNR.
  SORT LT_FIELD_DB BY TABCONTROL.
  LT_TABCONTROL = LT_FIELD_DB.
  DELETE ADJACENT DUPLICATES FROM LT_TABCONTROL COMPARING TABCONTROL.

  LOOP AT LT_TABCONTROL INTO LS_TABCONTROL.
    CONCATENATE '(' LPW_REPID ')' LS_TABCONTROL-TABCONTROL '-COLS'
      INTO LW_FNAME_PROG.
    ASSIGN (LW_FNAME_PROG) TO <LFT_COLUMNS>.
    LOOP AT LT_FIELD_DB INTO LS_FIELD_DB
      WHERE TABCONTROL                  = LS_TABCONTROL-TABCONTROL.
      IF LS_FIELD_DB-SUBSCR IS NOT INITIAL
      AND LS_FIELD_DB-SUBSCR <> LPW_DYNNR.
        CONTINUE.
      ENDIF.
      READ TABLE <LFT_COLUMNS> ASSIGNING <LF_COLUMN>
        WITH KEY SCREEN-NAME            = LS_FIELD_DB-FIELDNAME.
      IF SY-SUBRC IS INITIAL.
*       Inactive elements
        IF LS_FIELD_DB-FIELDSTS         = GC_FIELDSTS_INACTIVE.
          <LF_COLUMN>-INVISIBLE         = '1'.
*       Active elements (only if not label)
        ELSEIF LS_FIELD_DB-FIELDSTS IS NOT INITIAL.
          <LF_COLUMN>-INVISIBLE         = '0'.
          <LF_COLUMN>-SCREEN-INPUT      = LS_FIELD_DB-FIELDSTS+0(1).
          <LF_COLUMN>-SCREEN-OUTPUT     = LS_FIELD_DB-FIELDSTS+1(1).
*          <LF_COLUMN>-SCREEN-REQUIRED   = LS_FIELD_DB-FIELDSTS+2(1).
          <LF_COLUMN>-SCREEN-DISPLAY_3D = LS_FIELD_DB-FIELDSTS+3(1).
          IF LPW_MODE                   = GC_SMODE_DISPLAY.
            <LF_COLUMN>-SCREEN-INPUT    = '0'.
            <LF_COLUMN>-SCREEN-REQUIRED = '0'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " PBO_MODIFY_TABCONTROL

*&---------------------------------------------------------------------*
*&      Form  PBO_MODIFY_TABCONTROL_ROLE
*&---------------------------------------------------------------------*
*       Modify table control
*----------------------------------------------------------------------*
*      -->LPT_FIELD_DB  Field status
*----------------------------------------------------------------------*
FORM PBO_MODIFY_TABCONTROL_ROLE
  USING   LPT_ROLE_FLD    TYPE ZTT_BM_ROLE_FLD
          LPW_DYNNR       TYPE DYNNR
          LPW_REPID       TYPE REPID.
  DATA:
    LT_TABCONTROL TYPE TABLE OF ZST_BM_ROLE_FLD,
    LS_TABCONTROL TYPE ZST_BM_ROLE_FLD,
    LT_ROLE_FLD   TYPE TABLE OF ZST_BM_ROLE_FLD,
    LS_ROLE_FLD   TYPE ZST_BM_ROLE_FLD,
    LW_FNAME_PROG TYPE CHAR61.
  FIELD-SYMBOLS:
    <LF_COLUMN>   TYPE CXTAB_COLUMN,
    <LFT_COLUMNS> TYPE SCXTAB_COLUMN_IT.

  LT_ROLE_FLD[]           = LPT_ROLE_FLD[].
  DELETE LT_ROLE_FLD
    WHERE TABCONTROL IS INITIAL.
  SORT LT_ROLE_FLD BY TABCONTROL.
  LT_TABCONTROL = LT_ROLE_FLD.
  DELETE ADJACENT DUPLICATES FROM LT_TABCONTROL COMPARING TABCONTROL.

  LOOP AT LT_TABCONTROL INTO LS_TABCONTROL.
    CONCATENATE '(' LPW_REPID ')' LS_TABCONTROL-TABCONTROL '-COLS'
      INTO LW_FNAME_PROG.
    ASSIGN (LW_FNAME_PROG) TO <LFT_COLUMNS>.
    LOOP AT LT_ROLE_FLD INTO LS_ROLE_FLD
      WHERE TABCONTROL = LS_TABCONTROL-TABCONTROL.
      READ TABLE <LFT_COLUMNS> ASSIGNING <LF_COLUMN>
        WITH KEY SCREEN-NAME            = LS_ROLE_FLD-FULLFIELD.
      IF SY-SUBRC IS INITIAL.
*       Inactive elements
        IF LS_ROLE_FLD-FIELDSTS         = GC_FIELDSTS_INACTIVE.
          <LF_COLUMN>-INVISIBLE         = '1'.
*       Active elements (only if not label)
        ELSEIF LS_ROLE_FLD-FIELDSTS IS NOT INITIAL.
          IF <LF_COLUMN>-SCREEN-INPUT <> LS_ROLE_FLD-FIELDSTS+0(1).
            <LF_COLUMN>-SCREEN-INPUT      = '0'.
          ENDIF.
          IF <LF_COLUMN>-SCREEN-OUTPUT <> LS_ROLE_FLD-FIELDSTS+1(1).
            <LF_COLUMN>-SCREEN-OUTPUT     = '0'.
          ENDIF.
*          IF <LF_COLUMN>-SCREEN-REQUIRED <> LS_ROLE_FLD-FIELDSTS+2(1).
*            <LF_COLUMN>-SCREEN-REQUIRED   = '0'.
*          ENDIF.
          IF <LF_COLUMN>-SCREEN-DISPLAY_3D <> LS_ROLE_FLD-FIELDSTS+3(1).
            <LF_COLUMN>-SCREEN-DISPLAY_3D = '0'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " PBO_MODIFY_TABCONTROL_ROLE

*&---------------------------------------------------------------------*
*&      Form  9999_MODIFY_SGROUP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPT_FIELD_DB  text
*      <--LPSCREEN  text
*----------------------------------------------------------------------*
FORM 9999_MODIFY_SGROUP
  USING   LPT_FIELD_DB      TYPE ZTT_FIELD_DB
          I_DYNNR           TYPE DYNNR
          I_CLEAR_INACTIVE  TYPE XMARK
          I_MODE            TYPE ZDD_SCR_MODE
  CHANGING SCREEN           TYPE SCREEN.
  DATA:
    LS_SCREEN_GRP TYPE ZTB_FIELD_DB,
    LT_SCREEN_GRP TYPE ZTT_FIELD_DB,
    LS_FIELD_DB   TYPE ZTB_FIELD_DB.

  IF SCREEN-GROUP1 IS NOT INITIAL.
    LS_SCREEN_GRP-FIELDNAME = SCREEN-GROUP1.
    LS_SCREEN_GRP-SGROUP    = '1'.
    APPEND LS_SCREEN_GRP TO LT_SCREEN_GRP.
  ENDIF.
  IF SCREEN-GROUP2 IS NOT INITIAL.
    LS_SCREEN_GRP-FIELDNAME = SCREEN-GROUP2.
    LS_SCREEN_GRP-SGROUP    = '2'.
    APPEND LS_SCREEN_GRP TO LT_SCREEN_GRP.
  ENDIF.
  IF SCREEN-GROUP3 IS NOT INITIAL.
    LS_SCREEN_GRP-FIELDNAME = SCREEN-GROUP3.
    LS_SCREEN_GRP-SGROUP    = '3'.
    APPEND LS_SCREEN_GRP TO LT_SCREEN_GRP.
  ENDIF.
  IF SCREEN-GROUP4 IS NOT INITIAL.
    LS_SCREEN_GRP-FIELDNAME = SCREEN-GROUP4.
    LS_SCREEN_GRP-SGROUP    = '4'.
    APPEND LS_SCREEN_GRP TO LT_SCREEN_GRP.
  ENDIF.

  LOOP AT LT_SCREEN_GRP INTO LS_SCREEN_GRP.
*   Find field on screen group
    READ TABLE LPT_FIELD_DB INTO LS_FIELD_DB
      WITH KEY  FIELDNAME = LS_SCREEN_GRP-FIELDNAME
                SGROUP    = LS_SCREEN_GRP-SGROUP
                DYNNR     = I_DYNNR.
    IF SY-SUBRC IS INITIAL
    AND LS_FIELD_DB-FIELDSTS IS NOT INITIAL.
*     Inactive elements
      IF LS_FIELD_DB-FIELDSTS = GC_FIELDSTS_INACTIVE.
        SCREEN-ACTIVE = SCREEN-INPUT = SCREEN-OUTPUT = '0'.
        IF I_CLEAR_INACTIVE = GC_XMARK
        AND LS_FIELD_DB-FIELDNAME = SCREEN-NAME.
          PERFORM CLEAR_INACTIVE
            USING LS_FIELD_DB.
        ENDIF.
*     Active elements (only if not label)
      ELSEIF LS_FIELD_DB-FIELDSTS IS NOT INITIAL .
        IF SCREEN-NAME NS '*' AND SCREEN-NAME NS '%-TEXT'
         AND SCREEN-NAME NS '%-TO_TEXT'.
          SCREEN-INPUT      = LS_FIELD_DB-FIELDSTS+0(1).
          SCREEN-DISPLAY_3D = LS_FIELD_DB-FIELDSTS+3(1).
        ENDIF.
        SCREEN-OUTPUT     = LS_FIELD_DB-FIELDSTS+1(1).
        SCREEN-REQUIRED   = LS_FIELD_DB-FIELDSTS+2(1).
        IF I_MODE = GC_SMODE_DISPLAY.
          SCREEN-INPUT      = '0'.
          SCREEN-REQUIRED   = '0'.
        ENDIF.
      ENDIF.
*      MODIFY SCREEN.
    ELSEIF SY-SUBRC IS NOT INITIAL
    AND I_MODE = GC_SMODE_DISPLAY.
      SCREEN-INPUT      = '0'.
      SCREEN-REQUIRED   = '0'.
*      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " 9999_MODIFY_SGROUP

*&---------------------------------------------------------------------*
*&      Form  100_PBO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 100_PBO .
  LOOP AT SCREEN.
    IF ZST_BM_OUTTYP-SMF_DIS IS INITIAL
    AND SCREEN-NAME CS 'SMF'.
      SCREEN-ACTIVE = '0'.
      MODIFY SCREEN.
    ENDIF.
    IF ZST_BM_OUTTYP-EXC_DIS IS INITIAL
    AND SCREEN-NAME CS 'EXC'.
      SCREEN-ACTIVE = '0'.
      MODIFY SCREEN.
    ENDIF.
    IF ZST_BM_OUTTYP-ALV_DIS IS INITIAL
    AND SCREEN-NAME CS 'ALV'.
      SCREEN-ACTIVE = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " 100_PBO

*&---------------------------------------------------------------------*
*&      Form  9999_SET_FIELDS_TO_INTTAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  FIELDS        Fields to update
*  <--  ERROR         Errors
*----------------------------------------------------------------------*
FORM 9999_SET_FIELDS_TO_INTTAB
  TABLES   FIELDS STRUCTURE SVAL
  CHANGING ERROR  STRUCTURE SVALE.

  DATA:
    LW_WHERE_STR    TYPE STRING.
  FIELD-SYMBOLS:
    <LF_UPDTAB>     TYPE ANY.

  IF GW_UPDTAB_SELCHK IS INITIAL.
    LOOP AT <GFT_UPDTAB> ASSIGNING <LF_UPDTAB>.
      PERFORM 9999_SET_FIELDS_TO_RECORD
        USING    FIELDS[]
                 SPACE
        CHANGING <LF_UPDTAB>.
    ENDLOOP.
  ELSE.
    LW_WHERE_STR = 'SELECTED = GC_XMARK'.
    LOOP AT <GFT_UPDTAB> ASSIGNING <LF_UPDTAB>
      WHERE (LW_WHERE_STR).
      PERFORM 9999_SET_FIELDS_TO_RECORD
        USING    FIELDS[]
                 SPACE
        CHANGING <LF_UPDTAB>.
    ENDLOOP.
  ENDIF.


ENDFORM.                    " 9999_SET_FIELDS_TO_INTTAB

*&---------------------------------------------------------------------*
*&      Form  9999_BUILD_UPDFIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 9999_BUILD_UPDFIELDS
  USING LPW_SUB_TABNAME   TYPE TABNAME
        LPW_SUB_FNAME     TYPE FIELDNAME
        LPW_SUB_REQUIRED  TYPE XMARK
        LPS_REC_DEFAULT   TYPE ANY
  CHANGING LPT_FIELDS     TYPE TY_SVAL
           LPW_TITLE.
  DATA:
    LW_TABTYPE  TYPE TABNAME,
    LS_DD40V    TYPE DD40V,
    LT_FIELDCAT TYPE LVC_T_FCAT,
    LS_FIELDCAT TYPE LVC_S_FCAT,
    LS_SVAL     TYPE SVAL,
    LT_FNAME    TYPE RSDSSELOPT_T.
  FIELD-SYMBOLS:
    <LF_FIELDVAL>         TYPE ANY.

* Get structure name
  IF LPW_SUB_TABNAME IS INITIAL.
    DESCRIBE FIELD <GFT_UPDTAB> HELP-ID LW_TABTYPE.
    CALL FUNCTION 'DDIF_TTYP_GET'
      EXPORTING
        NAME     = LW_TABTYPE
      IMPORTING
        DD40V_WA = LS_DD40V
      EXCEPTIONS
        OTHERS   = 2.
  ELSE.
    LS_DD40V-ROWTYPE = LPW_SUB_TABNAME.
  ENDIF.

* Get fieldcat of Items table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME   = LS_DD40V-ROWTYPE
      I_INTERNAL_TABNAME = LS_DD40V-ROWTYPE
    CHANGING
      CT_FIELDCAT        = LT_FIELDCAT
    EXCEPTIONS
      OTHERS             = 3.

  CALL FUNCTION 'ZFM_SUBMIT_DATA_TO_SELOPT'
    EXPORTING
      I_LOW     = LPW_SUB_FNAME
    IMPORTING
      ER_SELOPT = LT_FNAME.


  LOOP AT LT_FIELDCAT INTO LS_FIELDCAT
    WHERE FIELDNAME IN LT_FNAME.
    LS_SVAL-TABNAME           = LS_FIELDCAT-TABNAME.
    LS_SVAL-FIELDNAME         = LS_FIELDCAT-FIELDNAME.
    LS_SVAL-FIELD_OBL         = LPW_SUB_REQUIRED.

    ASSIGN COMPONENT LS_FIELDCAT-FIELDNAME
      OF STRUCTURE LPS_REC_DEFAULT TO <LF_FIELDVAL>.
    IF SY-SUBRC IS INITIAL.
      LS_SVAL-VALUE           = <LF_FIELDVAL>.
      CONDENSE LS_SVAL-VALUE.
    ENDIF.


    IF LINES( LT_FNAME ) = 1
    AND LPW_TITLE IS INITIAL.
      CONCATENATE TEXT-009 LS_FIELDCAT-SCRTEXT_L
        INTO LPW_TITLE SEPARATED BY SPACE.
    ENDIF.

    APPEND LS_SVAL TO LPT_FIELDS.
  ENDLOOP.

ENDFORM.                    " 9999_BUILD_UPDFIELDS
*&---------------------------------------------------------------------*
*&      Form  9999_SET_FIELDS_TO_RECORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPT_FIELDS      Field values
*      -->LPW_UPD_INIT    Allow update init
*      <--LPS_UPDRECORD   Reocrd need to update
*----------------------------------------------------------------------*
FORM 9999_SET_FIELDS_TO_RECORD
  USING    LPT_FIELDS     TYPE TY_SVAL
           LPW_UPD_INIT   TYPE XMARK
  CHANGING LPS_UPDRECORD  TYPE ANY.

  DATA:
    LS_FIELD 	      TYPE SVAL.

  FIELD-SYMBOLS:
    <LF_UPDTAB> TYPE ANY,
    <LF_FIELD>  TYPE ANY.

  LOOP AT LPT_FIELDS INTO LS_FIELD.
    IF LPW_UPD_INIT IS INITIAL.
      CHECK LS_FIELD-VALUE IS NOT INITIAL.
    ENDIF.

    ASSIGN COMPONENT LS_FIELD-FIELDNAME OF STRUCTURE LPS_UPDRECORD
      TO <LF_FIELD>.
    IF SY-SUBRC IS INITIAL.
      <LF_FIELD> = LS_FIELD-VALUE.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " 9999_SET_FIELDS_TO_RECORD

*&---------------------------------------------------------------------*
*&      Form  9999_EXCEL_OUPUT_RETURN_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 9999_EXCEL_OUPUT_RETURN_INFO
  USING TASKNAME.
  DATA:
    LW_ANS            TYPE XMARK.
  FIELD-SYMBOLS:
    <LF_TASK>         TYPE ZST_BM_TASK.

  RECEIVE RESULTS FROM FUNCTION 'ZFM_RP_OUTPUT_EXCEL_SHEETS_MT'
    EXCEPTIONS
      COMMUNICATION_FAILURE = 1
      SYSTEM_FAILURE        = 2
      NO_CONFIG             = 3
      NO_FIELD_SHEETNAME    = 4.

* Calculate Receiving jobs
  GS_MULTITHREAD-RECV_JOBS = GS_MULTITHREAD-RECV_JOBS + 1.
  IF SY-SUBRC NE 0.
*  * Handle communication and system failure
    ...
  ELSE.
    READ TABLE GS_MULTITHREAD-TASKLIST ASSIGNING <LF_TASK>
      WITH KEY TASKNAME = TASKNAME.
    IF SY-SUBRC = 0.  "Register data
      <LF_TASK>-RECEIVED    = GC_XMARK.
      <LF_TASK>-RECV_INDEX  = GS_MULTITHREAD-RECV_JOBS.
    ENDIF.
  ENDIF.

ENDFORM.                    " 9999_EXCEL_OUPUT_RETURN_INFO

*&---------------------------------------------------------------------*
*&      Form  9999_GET_EXCEL_CONFIG
*&---------------------------------------------------------------------*
*       Get excel config
*----------------------------------------------------------------------*
*      -->LPW_REPORT  text
*----------------------------------------------------------------------*
FORM 9999_GET_EXCEL_CONFIG
  USING    LPW_REPORT     TYPE SY-REPID.

  READ TABLE GT_EX_SHEETS TRANSPORTING NO FIELDS
    WITH KEY REPID = LPW_REPORT BINARY SEARCH.
  CHECK SY-SUBRC IS NOT INITIAL.

* Get list of sheets
  SELECT *
    INTO TABLE GT_EX_SHEETS
    FROM ZTB_EXCEL_SHEETS
   WHERE REPID = LPW_REPORT.
  SORT GT_EX_SHEETS BY REPID SHEETNO.
*  IF GT_EX_SHEETS[] IS INITIAL.
*    MESSAGE E008 WITH I_REPORT RAISING NO_CONFIG.
*  ENDIF.

* Get Sheet layout
  SELECT *
    INTO TABLE GT_EX_SHEET_LAYOUT
    FROM ZTB_SHEET_LAYOUT
   WHERE REPORT  = LPW_REPORT.
  SORT GT_EX_SHEET_LAYOUT BY REPORT SHEETNO FNAME POSID.
*  IF GT_EX_SHEETS[] IS INITIAL.
*    MESSAGE E008 WITH I_REPORT RAISING NO_CONFIG.
*  ENDIF.
ENDFORM.                    " 9999_GET_EXCEL_CONFIG

*&---------------------------------------------------------------------*
*&      Form  9999_CONVERT_TAB2EXDAT
*&---------------------------------------------------------------------*
*       Convert table data to excel data
*----------------------------------------------------------------------*
*      -->LPW_FILENAME  text
*      -->LPT_DATA  text
*      <--LPS_EXFILE_DATA  text
*----------------------------------------------------------------------*
FORM 9999_CONVERT_TAB2EXDAT
  USING    LPW_REPID        TYPE SY-REPID
           LPT_DATA         TYPE TABLE
  CHANGING LPS_EXFILE_DATA  TYPE ZST_EXFILE_DATA.
  DATA:
    LS_SHEET          TYPE ZTB_EXCEL_SHEETS,
    LS_SHEET_LAYOUT   TYPE ZTB_SHEET_LAYOUT,
    LT_EXCEL_LAYOUT   TYPE TABLE OF ZTB_EXCEL_LAYOUT,
    LS_EXCEL_LAYOUT   TYPE ZTB_EXCEL_LAYOUT,
    LW_WHERE_STR      TYPE STRING,
    LT_SHEET_EXDAT    TYPE ZTT_SHEET_DATA,
    LS_SHEET_EXDAT    TYPE ZST_SHEET_DATA,
    LW_NO_SAME_SHT    TYPE I,
*   Number of insert sheet: To correct sheet index
    LW_NO_SHT_INS     TYPE I,
    LS_EXCEL_FILE_OUT TYPE ZST_EXCEL_FILE_OUT.
  FIELD-SYMBOLS:
    <LF_SHEET_DATA> TYPE ANY,
    <LF_CPSHEET>    TYPE TEXT256.

  SORT GT_EX_SHEETS BY SHEETNO.
  LOOP AT GT_EX_SHEETS INTO LS_SHEET
    WHERE REPID = LPW_REPID.
*   Increase number of sheet was inserted for next process
    IF LW_NO_SAME_SHT > 0.
      LW_NO_SHT_INS    = LW_NO_SHT_INS + LW_NO_SAME_SHT - 1.
    ENDIF.

*   Read sheet data with sheet no or same original sheet no
    LW_WHERE_STR = LS_SHEET-SHEETNO.
    CONCATENATE GC_FIELD_SHEETNO ' = ' LW_WHERE_STR
           INTO LW_WHERE_STR SEPARATED BY SPACE.
    CLEAR: LW_NO_SAME_SHT.
    LOOP AT LPT_DATA ASSIGNING <LF_SHEET_DATA> WHERE (LW_WHERE_STR).
*     Init
      CLEAR: LS_SHEET_EXDAT, LT_EXCEL_LAYOUT[].
      LW_NO_SAME_SHT = LW_NO_SAME_SHT + 1.

*     No have original to copy
      IF LS_SHEET-CPSHEET IS INITIAL.
*       Sheet number = sheet number in config
        LS_SHEET_EXDAT-SHEETNO      = LS_SHEET-SHEETNO.
        LS_SHEET_EXDAT-SHEET_NAME   = LS_SHEET-SHEETNAME.
      ELSE.
*       Sheet number: Increase from original sheet index
*       Note: Correct sheet number when insert new sheet: LW_NO_SHT_INS
        LS_SHEET_EXDAT-ORG_SHEETIX  = LS_SHEET-SHEETNO + LW_NO_SHT_INS.
        LS_SHEET_EXDAT-SHEETNO      = LS_SHEET-SHEETNO + LW_NO_SHT_INS
                                    + LW_NO_SAME_SHT - 1.
        ASSIGN COMPONENT LS_SHEET-CPSHEET OF STRUCTURE <LF_SHEET_DATA>
          TO <LF_CPSHEET>.
        IF SY-SUBRC IS INITIAL.
          LS_SHEET_EXDAT-SHEET_NAME = <LF_CPSHEET>.
        ELSE.
          MESSAGE E009 RAISING NO_FIELD_SHEETNAME.
        ENDIF.
      ENDIF.

*     Get layout config each sheet
      LOOP AT GT_EX_SHEET_LAYOUT INTO LS_SHEET_LAYOUT
        WHERE REPORT  = LPW_REPID
          AND SHEETNO = LS_SHEET-SHEETNO.
        MOVE-CORRESPONDING LS_SHEET_LAYOUT TO LS_EXCEL_LAYOUT.
        APPEND LS_EXCEL_LAYOUT TO LT_EXCEL_LAYOUT.
      ENDLOOP.

*     Get header data to export
      CALL FUNCTION 'ZFM_FILE_EXCEL_GET_HEADER'
        EXPORTING
          I_REPORT       = LPW_REPID
          I_HEADER       = <LF_SHEET_DATA>
          T_EXCEL_LAYOUT = LT_EXCEL_LAYOUT
          I_LARGE_FILE   = GC_XMARK
        IMPORTING
          E_PAGESETUP    = LS_SHEET_EXDAT-I_PAGESETUP
          T_EXCEL_EXP    = LS_SHEET_EXDAT-T_SQUARE_DATA.

*     Get item data to export
      CALL FUNCTION 'ZFM_FILE_EXCEL_GET_ITEMS_NUM'
        EXPORTING
          I_REPORT       = LPW_REPID
          I_DATA         = <LF_SHEET_DATA>
          T_EXCEL_LAYOUT = LT_EXCEL_LAYOUT
        IMPORTING
          T_EXCEL_EXP    = LS_SHEET_EXDAT-T_SQUARE_DATA.
      APPEND LS_SHEET_EXDAT TO LT_SHEET_EXDAT.
    ENDLOOP.
  ENDLOOP.

  LPS_EXFILE_DATA-SHEETSDATA  = LT_SHEET_EXDAT.
ENDFORM.                    " 9999_CONVERT_TAB2EXDAT

*&---------------------------------------------------------------------*
*&      Form  RECEIVE_DEMO_PARALLEL_RFC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM RECEIVE_DEMO_PARALLEL_RFC
  USING TASKNAME.
  DATA:
    LS_INFO       TYPE RFCSI.
  FIELD-SYMBOLS:
    <LF_TASK>    TYPE ZST_BM_TASK.

  RECEIVE RESULTS FROM FUNCTION 'RFC_SYSTEM_INFO'
    IMPORTING
      RFCSI_EXPORT = LS_INFO
    EXCEPTIONS
      COMMUNICATION_FAILURE = 1
      SYSTEM_FAILURE  = 2.

  GS_MULTITHREAD-RECV_JOBS = GS_MULTITHREAD-RECV_JOBS + 1.
  IF SY-SUBRC NE 0.
  ELSE.
    READ TABLE GS_MULTITHREAD-TASKLIST ASSIGNING <LF_TASK>
      WITH KEY TASKNAME = TASKNAME.
    IF SY-SUBRC = 0.  "Register data
      <LF_TASK>-RFCHOST     = LS_INFO-RFCHOST.
      <LF_TASK>-RECV_INDEX  = GS_MULTITHREAD-RECV_JOBS.
    ENDIF.
  ENDIF.

ENDFORM.                    " RECEIVE_DEMO_PARALLEL_RFC

*&---------------------------------------------------------------------*
*&      Form  9999_CHECK_XLWB_FORM_EXISTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IV_FORMNAME  text
*----------------------------------------------------------------------*
FORM 9999_CHECK_XLWB_FORM_EXISTS
  USING  LPW_FORMNAME      TYPE ANY.

  DATA:
    LW_OBJID                  TYPE WWWDATATAB-OBJID.

  CONCATENATE GC_XLWB_FORM_PREF LPW_FORMNAME  INTO LW_OBJID.
  SELECT SINGLE OBJID
    INTO LW_OBJID
    FROM WWWDATA
   WHERE RELID    EQ GC_XLWB_RELID
     AND OBJID    EQ LW_OBJID
     AND SRTF2    EQ 0.
  IF SY-SUBRC IS NOT INITIAL.
    MESSAGE S013 DISPLAY LIKE GC_MTYPE_E
      WITH LPW_FORMNAME RAISING FORM_NOT_EXISTS.
    RETURN.
  ENDIF.
ENDFORM.                    " 9999_CHECK_XLWB_FORM_EXISTS
