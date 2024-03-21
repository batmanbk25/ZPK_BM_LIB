*&---------------------------------------------------------------------*
*&  Include           ZIN_UPDATE_DBF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  MAIN_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MAIN_PROC .

  GW_USE_DYNAMIC_SELECTION = 'X'.
  PERFORM CREATE_STRUCTURE.

  IF GW_USE_DYNAMIC_SELECTION = SPACE.
    CALL SCREEN 200.
  ELSE.
    PERFORM FREE_SELECTION.
  ENDIF.

ENDFORM.                    " MAIN_PROC
*&---------------------------------------------------------------------*
*&      Form  LEAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LEAVE .
  CASE SY-UCOMM.
    WHEN 'BACK' OR 'CANCEL'.
      IF GW_USE_DYNAMIC_SELECTION = 'X'.
        PERFORM FREE_SELECTION.
      ENDIF.
      SET SCREEN 0.
    WHEN 'EXIT' .
      LEAVE PROGRAM.
  ENDCASE.
ENDFORM.                    " LEAVE
*&---------------------------------------------------------------------*
*&      Form  BUILD_WHERE_CLAUSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_WHERE_CLAUSE.
  DATA:
    LS_SELECTION  TYPE GTY_SELECTION,
    LS_RANGE      TYPE GTY_S_RANGES_TAB,
    LS_WHERE      TYPE RSDSWHERE,
    LT_WHERE      TYPE RSDS_WHERE_TAB.

  CLEAR: GT_SELECTION[],
         GT_WHERE_CLAUSES[].
  LS_RANGE-SIGN = 'I'.
  LS_RANGE-OPTION = 'EQ'.
  LS_SELECTION-LOG_COND   = 'AND'.          "Logical condition

  LOOP AT GT_FIELDS INTO GS_FIELD WHERE VALUE IS NOT INITIAL.
    CLEAR LS_SELECTION-RANGES_TAB[].
    LS_SELECTION-FIELDNAME = GS_FIELD-FIELDNAME.
    LS_RANGE-LOW = GS_FIELD-VALUE.
    APPEND LS_RANGE TO LS_SELECTION-RANGES_TAB.
    APPEND LS_SELECTION TO GT_SELECTION.
  ENDLOOP.
  IF GT_SELECTION[] IS INITIAL.
    RETURN.
  ENDIF.
  LS_WHERE = '('.
  APPEND LS_WHERE TO GT_WHERE_CLAUSES.

* Generate where clause
  CALL FUNCTION 'ADSPC_CREATE_WHERE_CLAUSE'
    TABLES
      SELECTION_TAB = GT_SELECTION          "Range table
      WHERE_CLAUSE  = LT_WHERE.             "Where clause
  IF SY-SUBRC = 0.
    APPEND LINES OF LT_WHERE TO GT_WHERE_CLAUSES.

*   Add ')' mark at the end
    CLEAR LS_WHERE.
    LS_WHERE = ')'.
    APPEND LS_WHERE TO GT_WHERE_CLAUSES.
  ELSE.     "No data returned
    CLEAR GT_WHERE_CLAUSES.
  ENDIF.

ENDFORM.                    " BUILD_WHERE_CLAUSE
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA.
  DATA:
*    LT_DATA_TABLE   LIKE <GFT_DATA_TABLE>,
    LW_WHERE_CLAUSE TYPE STRING,
    LW_POS          TYPE I,
    LS_WHERE        TYPE RSDSWHERE.

* Init
  CLEAR <GFT_DATA_TABLE>.
  CALL FUNCTION 'ZFM_DATTAB_GET'
    EXPORTING
      I_TABLE         = P_TABLE
      T_WHERE_CLAUSES = GT_WHERE_CLAUSES
    IMPORTING
      T_TABLE_DATA    = <GFT_DATA_TABLE>.
  <GFT_DATA_OLD>[] = <GFT_DATA_TABLE>[].
  <GFT_DATA_ORG>[] = <GFT_DATA_TABLE>[].
  CALL SCREEN 100.
  RETURN.

* Check where clause
  IF GT_WHERE_CLAUSES IS NOT INITIAL.
*   Make where clause
    CLEAR:  LW_WHERE_CLAUSE.
    LOOP AT GT_WHERE_CLAUSES INTO LS_WHERE.
      CONCATENATE LW_WHERE_CLAUSE
                  LS_WHERE
             INTO LW_WHERE_CLAUSE SEPARATED BY SPACE.
    ENDLOOP.

*   Get data from database
    SELECT *
      INTO TABLE <GFT_DATA_TABLE>
      FROM (P_TABLE)
      WHERE (LW_WHERE_CLAUSE).
  ELSE.

*   Get data from database
    SELECT *
      INTO TABLE <GFT_DATA_TABLE>
      FROM (P_TABLE).
  ENDIF.

** Check data got
*  IF <GFT_DATA_TABLE>[] IS NOT INITIAL.
**   Save to old table
*    <GFT_DATA_OLD>[] = <GFT_DATA_TABLE>[].
*    <GFT_DATA_ORG>[] = <GFT_DATA_TABLE>[].
*    CALL SCREEN 100.
*  ELSE.
*    MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
*  ENDIF.
* Save to old table
  <GFT_DATA_OLD>[] = <GFT_DATA_TABLE>[].
  <GFT_DATA_ORG>[] = <GFT_DATA_TABLE>[].
  CALL SCREEN 100.

ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA_100 .

  DATA:
*   Layout
    LS_LAYOUT     TYPE LVC_S_LAYO,
    LT_FIELD_CAT  TYPE LVC_T_FCAT.

  LS_LAYOUT-GRID_TITLE  = TEXT-012.
  LS_LAYOUT-EDIT_MODE   = 'X'.
  LS_LAYOUT-EDIT        = 'X'.
  LS_LAYOUT-SEL_MODE    = 'B'.
  LS_LAYOUT-BOX_FNAME   = 'SELECT'.
  LS_LAYOUT-CWIDTH_OPT  = 'X'.
*  LS_LAYOUT-NO_ROWMARK  = 'X'.


  CLEAR LT_FIELD_CAT.
* Fix for EPH6
*  MOVE-CORRESPONDING GT_FIELDS TO LT_FIELD_CAT.
  CALL FUNCTION 'ZFM_DATA_TABLE_MOVE_CORRESPOND'
    CHANGING
      C_SRC_TAB       = GT_FIELDS
      C_DES_TAB       = LT_FIELD_CAT.

* Create container object
  CREATE OBJECT ZCTR_ALV_CONTAINER
    EXPORTING
      CONTAINER_NAME              = 'ZCTR_ALV_CONTAINER'
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.

  IF ZCTR_ALVGRID IS INITIAL.
*   Khoi tao ALV grid
    CREATE OBJECT ZCTR_ALVGRID
      EXPORTING
        I_PARENT = ZCTR_ALV_CONTAINER.
  ENDIF.

  CALL METHOD ZCTR_ALVGRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_STRUCTURE_NAME              = P_TABLE
      IS_LAYOUT                     = LS_LAYOUT
    CHANGING
      IT_OUTTAB                     = <GFT_DATA_TABLE>
      IT_FIELDCATALOG               = LT_FIELD_CAT
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " DISPLAY_DATA_100
*&---------------------------------------------------------------------*
*&      Form  CREATE_STRUCTURE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_STRUCTURE .
  DATA:LT_DATA TYPE REF TO DATA,
       LS_DATA TYPE REF TO DATA,
       LT_FIELD_CAT        TYPE LVC_T_FCAT,
       LW_USING_KEY TYPE CHAR256.

  CLEAR: GT_FIELDS, GT_KEYS.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME = P_TABLE
      I_BYPASSING_BUFFER  = 'X'
    CHANGING
      CT_FIELDCAT      = LT_FIELD_CAT[].

  APPEND LINES OF LT_FIELD_CAT[] TO GT_FIELDS[].
  SORT GT_FIELDS BY COL_POS.
  LOOP AT GT_FIELDS INTO GS_FIELD.
*   Get key field
    IF GS_FIELD-KEY = 'X'.
      APPEND GS_FIELD-FIELDNAME TO GT_KEYS.
    ENDIF.
    IF SY-TABIX > 10.
      GS_FIELD-NO_OUT     = 'X'.
    ENDIF.
*    IF GS_FIELD-INTLEN < 5.
*      GS_FIELD-OUTPUTLEN = 10.
*    ENDIF.
    GS_FIELD-TABNAME  = P_TABLE.
    MODIFY GT_FIELDS FROM GS_FIELD INDEX SY-TABIX.
  ENDLOOP.

*  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
*    EXPORTING
*      IT_FIELDCATALOG = LT_FIELD_CAT[]
*    IMPORTING
*      EP_TABLE        = GT_DATA.

  PERFORM GET_CONDITION_BY_KEY
    USING '<GF_DATA_STR>'
    CHANGING LW_USING_KEY.
  CREATE DATA GT_DATA TYPE STANDARD TABLE OF
         (P_TABLE) WITH KEY (GT_KEYS).
  ASSIGN GT_DATA->* TO <GFT_DATA_TABLE>.
  CREATE DATA LT_DATA LIKE <GFT_DATA_TABLE>.
  ASSIGN LT_DATA->* TO <GFT_DATA_OLD>.
  CREATE DATA LT_DATA LIKE <GFT_DATA_TABLE>.
  ASSIGN LT_DATA->* TO <GFT_DATA_ORG>.
  CREATE DATA LS_DATA LIKE LINE OF <GFT_DATA_TABLE>.
  ASSIGN LS_DATA->* TO <GF_DATA_STR>.

ENDFORM.                    " CREATE_STRUCTURE
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_DATA .
  DATA: LT_DATA       TYPE REF TO DATA,
        LS_DATA       TYPE REF TO DATA,
        LW_VALID      TYPE C,
        LW_USING_KEY  TYPE CHAR256.
  FIELD-SYMBOLS:
    <LF_DATA_STR>     TYPE ANY,
    <LFT_DATA_INSERT> TYPE TABLE,
    <LFT_DATA_UPDATE> TYPE TABLE,
    <LFT_DATA_DELETE> TYPE TABLE.

*  CLEAR: <LFT_DATA_INSERT>,
*    <LFT_DATA_UPDATE>,
*    <LFT_DATA_DELETE>.

* Create structure data
  CREATE DATA LS_DATA LIKE LINE OF <GFT_DATA_TABLE>.
  ASSIGN LS_DATA->* TO <LF_DATA_STR>.

* Create structure of 3 tables insert, update, delete
  CREATE DATA LT_DATA LIKE <GFT_DATA_TABLE>.
  ASSIGN LT_DATA->* TO <LFT_DATA_DELETE>.

  CREATE DATA LT_DATA LIKE <GFT_DATA_TABLE>.
  ASSIGN LT_DATA->* TO <LFT_DATA_UPDATE>.

  CREATE DATA LT_DATA LIKE <GFT_DATA_TABLE>.
  ASSIGN LT_DATA->* TO <LFT_DATA_INSERT>.

* Check data change
  CALL METHOD ZCTR_ALVGRID->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LW_VALID.
  IF LW_VALID IS INITIAL.
    MESSAGE 'There is no change' TYPE 'S'.
    RETURN.
  ENDIF.

* Get condition by keys
  PERFORM GET_CONDITION_BY_KEY
    USING '<GF_DATA_STR>'
    CHANGING LW_USING_KEY.
* Get change info
  LOOP AT <GFT_DATA_TABLE> ASSIGNING <GF_DATA_STR>.
*   Find old record
    READ TABLE <GFT_DATA_OLD> FROM <GF_DATA_STR>
    ASSIGNING <LF_DATA_STR>."with KEY (LW_USING_KEY)
    IF SY-SUBRC IS NOT INITIAL.
*     Not found old record, will insert
      APPEND <GF_DATA_STR> TO <LFT_DATA_INSERT>.
    ELSE.
*     Found, check data change
      IF <GF_DATA_STR> <> <LF_DATA_STR>.
*       Changed, will update
        APPEND <GF_DATA_STR> TO <LFT_DATA_UPDATE>.
      ENDIF.
*     Found, delete to next loop
      DELETE TABLE <GFT_DATA_OLD> FROM <GF_DATA_STR>.
    ENDIF.
  ENDLOOP.
* Get all deleted record
  APPEND LINES OF <GFT_DATA_OLD> TO <LFT_DATA_DELETE>.
* Delete in database
  IF <LFT_DATA_DELETE> IS NOT INITIAL.
    TRY.
        DELETE (P_TABLE) FROM TABLE <LFT_DATA_DELETE>.
      CATCH CX_SY_OPEN_SQL_DB.
        ROLLBACK WORK.
        MESSAGE 'Update unsuccessfully' TYPE 'S' DISPLAY LIKE 'E'.
        <GFT_DATA_TABLE>[] = <GFT_DATA_ORG>[].
        RETURN.
    ENDTRY.
*    DELETE (P_TABLE) FROM TABLE <LFT_DATA_DELETE>.
    IF SY-SUBRC IS NOT INITIAL.
      ROLLBACK WORK.
      MESSAGE 'Delete unsuccessfully' TYPE 'S' DISPLAY LIKE 'E'.
      <GFT_DATA_TABLE>[] = <GFT_DATA_ORG>[].
      RETURN.
    ENDIF.
  ENDIF.

* Update in database
  IF <LFT_DATA_UPDATE> IS NOT INITIAL.
    TRY.
        UPDATE (P_TABLE) FROM TABLE <LFT_DATA_UPDATE>.
      CATCH CX_SY_OPEN_SQL_DB.
        ROLLBACK WORK.
        MESSAGE 'Update unsuccessfully' TYPE 'S' DISPLAY LIKE 'E'.
        <GFT_DATA_TABLE>[] = <GFT_DATA_ORG>[].
        RETURN.
    ENDTRY.
*    UPDATE (P_TABLE) FROM TABLE <LFT_DATA_UPDATE>.
    IF SY-SUBRC IS NOT INITIAL.
      ROLLBACK WORK.
      MESSAGE 'Update unsuccessfully' TYPE 'S' DISPLAY LIKE 'E'.
      <GFT_DATA_TABLE>[] = <GFT_DATA_ORG>[].
      RETURN.
    ENDIF.
  ENDIF.
* Insert in database
  IF <LFT_DATA_INSERT> IS NOT INITIAL.
    TRY.
        INSERT (P_TABLE) FROM TABLE <LFT_DATA_INSERT>.
      CATCH CX_SY_OPEN_SQL_DB.
        ROLLBACK WORK.
        MESSAGE 'Update unsuccessfully' TYPE 'S' DISPLAY LIKE 'E'.
        <GFT_DATA_TABLE>[] = <GFT_DATA_ORG>[].
        RETURN.
    ENDTRY.
*    INSERT (P_TABLE) FROM TABLE <LFT_DATA_INSERT>.
    IF SY-SUBRC IS NOT INITIAL.
      ROLLBACK WORK.
      MESSAGE 'Insert unsuccessfully' TYPE 'S' DISPLAY LIKE 'E'.
      <GFT_DATA_TABLE>[] = <GFT_DATA_ORG>[].
      RETURN.
    ENDIF.
  ENDIF.
* Save to old table
  <GFT_DATA_OLD>[] = <GFT_DATA_TABLE>[].
  <GFT_DATA_ORG>[] = <GFT_DATA_TABLE>[].
  COMMIT WORK.
  MESSAGE 'Save successfully' TYPE 'S'.

ENDFORM.                    " SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_CONDITION_BY_KEY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPW_USING_KEY  text
*----------------------------------------------------------------------*
FORM GET_CONDITION_BY_KEY
  USING     LPW_FIELDNAME TYPE FIELDNAME
  CHANGING  LPW_USING_KEY TYPE CHAR256.

  DATA:
    LW_FIELDNAME TYPE FIELDNAME,
    LW_DATA_NAME  TYPE FIELDNAME.

*      LPW_USING_KEY = 'WITH KEY'.
  LOOP AT GT_KEYS INTO LW_FIELDNAME.
*      CONCATENATE LPW_FIELDNAME
*                  '-'
*                  LW_FIELDNAME
*             INTO LW_DATA_NAME.
*      CONCATENATE LPW_USING_KEY
*                  LW_FIELDNAME
*                  '='
*                  LW_DATA_NAME
*             INTO LPW_USING_KEY
*             SEPARATED BY SPACE.

    CONCATENATE LPW_USING_KEY
                LW_FIELDNAME
           INTO LPW_USING_KEY
           SEPARATED BY SPACE.
  ENDLOOP.
ENDFORM.                    " GET_CONDITION_BY_KEY

*&---------------------------------------------------------------------*
*&      Form  FREE_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FREE_SELECTION .

  TYPE-POOLS: RSDS.
  DATA:
    LW_SEL_ID       TYPE RSDYNSEL-SELID,
    LS_RSDSTABS     TYPE RSDSTABS,
    LT_RSDSTABS     TYPE TABLE OF RSDSTABS,
    LS_RSDSFIELDS   TYPE RSDSFIELDS,
    LT_RSDSFIELDS   TYPE TABLE OF RSDSFIELDS,
    LT_FIELDCAT     TYPE LVC_T_FCAT ,
    LS_FIELDCAT     TYPE LVC_S_FCAT,
    LT_RSDS_TRANGE  TYPE RSDS_TRANGE,
    LT_RSDS_TWHERE  TYPE RSDS_TWHERE,
    LS_RSDS_TWHERE  LIKE LINE OF LT_RSDS_TWHERE,
    LT_RSDSFCODE    TYPE TABLE OF RSDSFCODE,
    LS_RSDSFCODE    TYPE RSDSFCODE,
    LS_PFKEY        TYPE RSDSPFKEY.

  IF SY-UNAME = 'TUANBA' OR SY-UNAME = 'CT.ABAPHN'.
    CALL FUNCTION 'ZFM_DATTAB_FREE_SELECTION'
      EXPORTING
        I_TABLE         = P_TABLE
        I_MAXSELECT     = 12
      IMPORTING
        T_WHERE_CLAUSES = GT_WHERE_CLAUSES
      CHANGING
        C_SELID         = GW_SEL_ID
      EXCEPTIONS
        ERROR           = 1
        OTHERS          = 2.
    IF SY-SUBRC = 0.
      IF P_DELDAT IS INITIAL.
        PERFORM GET_DATA.
      ELSE.
        DELETE FROM (P_TABLE)
        WHERE (GT_WHERE_CLAUSES).
      ENDIF.
    ENDIF.
    RETURN.
  ENDIF.

* Get table name
  LS_RSDSTABS-PRIM_TAB = P_TABLE.
  APPEND LS_RSDSTABS TO LT_RSDSTABS.

* Get structure of table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = P_TABLE
    CHANGING
      CT_FIELDCAT            = LT_FIELDCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

* Create structure of table for dynamic selection
  LOOP AT LT_FIELDCAT INTO LS_FIELDCAT.
    CHECK LS_FIELDCAT-FIELDNAME <> 'MANDT'
      AND LS_FIELDCAT-ROLLNAME  <> 'MANDT'
      AND LS_FIELDCAT-DD_ROLL   <> 'MANDT'
      AND LS_FIELDCAT-DOMNAME   <> 'MANDT'.
    LS_RSDSFIELDS-TABLENAME   = LS_RSDSTABS-PRIM_TAB.
    LS_RSDSFIELDS-FIELDNAME   = LS_FIELDCAT-FIELDNAME.
    LS_RSDSFIELDS-TYPE        = LS_FIELDCAT-INTTYPE.
    LS_RSDSFIELDS-WHERE_LENG  = LS_FIELDCAT-INTLEN.
    LS_RSDSFIELDS-DECIMALS    = LS_FIELDCAT-DECIMALS.
    APPEND LS_RSDSFIELDS TO LT_RSDSFIELDS.
  ENDLOOP.

* Maximum 10 field to pre-select
  DELETE LT_RSDSFIELDS FROM 10.

* Init dynamic selection
  CALL FUNCTION 'FREE_SELECTIONS_INIT'
    EXPORTING
      ALV                      = 'X'
      FIELD_RANGES_INT         = GT_RSDS_TRANGE
    IMPORTING
      SELECTION_ID             = LW_SEL_ID
    TABLES
      TABLES_TAB               = LT_RSDSTABS
      FIELDS_TAB               = LT_RSDSFIELDS
    EXCEPTIONS
      FIELDS_INCOMPLETE        = 1
      FIELDS_NO_JOIN           = 2
      FIELD_NOT_FOUND          = 3
      NO_TABLES                = 4
      TABLE_NOT_FOUND          = 5
      EXPRESSION_NOT_SUPPORTED = 6
      INCORRECT_EXPRESSION     = 7
      ILLEGAL_KIND             = 8
      AREA_NOT_FOUND           = 9
      INCONSISTENT_AREA        = 10
      KIND_F_NO_FIELDS_LEFT    = 11
      KIND_F_NO_FIELDS         = 12
      TOO_MANY_FIELDS          = 13
      DUP_FIELD                = 14
      FIELD_NO_TYPE            = 15
      FIELD_ILL_TYPE           = 16
      DUP_EVENT_FIELD          = 17
      NODE_NOT_IN_LDB          = 18
      AREA_NO_FIELD            = 19
      OTHERS                   = 20.

* Display screen for select
  CLEAR: LT_RSDSFIELDS[], LT_RSDSFCODE[], GT_WHERE_CLAUSES[].
  LS_RSDSFCODE-FCODE  = 'BACK'.
  LS_RSDSFCODE-FORM   = 'LEAVE'.
  APPEND LS_RSDSFCODE TO LT_RSDSFCODE.
  LS_RSDSFCODE-FCODE  = 'EXIT'.
  APPEND LS_RSDSFCODE TO LT_RSDSFCODE.
  LS_RSDSFCODE-FCODE  = 'DCAN'.
  APPEND LS_RSDSFCODE TO LT_RSDSFCODE.
* PF Status
  LS_PFKEY-PFKEY    = 'ZGS_200'.
  LS_PFKEY-PROGRAM  = SY-REPID.

  CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
    EXPORTING
      SELECTION_ID    = LW_SEL_ID
      ALV             = 'X'
      TITLE           = 'Selection'
      STATUS          = 1
*     PFKEY           = LS_PFKEY
    IMPORTING
      WHERE_CLAUSES   = LT_RSDS_TWHERE
      FIELD_RANGES    = GT_RSDS_TRANGE
    TABLES
      FIELDS_TAB      = LT_RSDSFIELDS
      FCODE_TAB       = LT_RSDSFCODE
    EXCEPTIONS
      INTERNAL_ERROR  = 1
      NO_ACTION       = 2
      SELID_NOT_FOUND = 3
      ILLEGAL_STATUS  = 4
      OTHERS          = 5.
  IF SY-SUBRC = 0.
    IF LT_RSDS_TWHERE[] IS NOT INITIAL.
      READ TABLE LT_RSDS_TWHERE INDEX 1 INTO LS_RSDS_TWHERE.
      GT_WHERE_CLAUSES = LS_RSDS_TWHERE-WHERE_TAB.
    ENDIF.
    PERFORM GET_DATA.
  ENDIF.
ENDFORM.                    " FREE_SELECTION

*&---------------------------------------------------------------------*
*&      Form  DELETE_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DELETE_ALL .
  DATA:
    LW_ANSWER     TYPE C.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-001
      TEXT_QUESTION         = TEXT-002
      DISPLAY_CANCEL_BUTTON = ''
    IMPORTING
      ANSWER                = LW_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.
  CHECK LW_ANSWER = '1'.

  TRY.
      DELETE (P_TABLE) FROM TABLE <GFT_DATA_TABLE>.
    CATCH CX_SY_OPEN_SQL_DB.
      ROLLBACK WORK.
      MESSAGE 'Delete unsuccessfully' TYPE 'S' DISPLAY LIKE 'E'.
      <GFT_DATA_TABLE>[] = <GFT_DATA_ORG>[].
      RETURN.
  ENDTRY.
*    DELETE (P_TABLE) FROM TABLE <LFT_DATA_DELETE>.
  IF SY-SUBRC IS NOT INITIAL.
    ROLLBACK WORK.
    MESSAGE 'Delete unsuccessfully' TYPE 'S' DISPLAY LIKE 'E'.
    <GFT_DATA_TABLE>[] = <GFT_DATA_ORG>[].
    RETURN.
  ENDIF.
  COMMIT WORK AND WAIT.
  CLEAR <GFT_DATA_TABLE>.
  MESSAGE 'Delete successfully' TYPE 'S'.
ENDFORM.                    " DELETE_ALL
