*&---------------------------------------------------------------------*
*&  Include           LZFG_DATA_PROCESSF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  BUILD_WHERE_CLAUSE
*&---------------------------------------------------------------------*
*       Build where clause to select
*----------------------------------------------------------------------*
FORM BUILD_WHERE_CLAUSE
  USING T_TABLE_CURRENT   TYPE ANY TABLE.

  DATA:
    LS_SELECTION  TYPE GTY_SELECTION,
    LS_RANGE      TYPE GTY_S_RANGES_TAB,
    LS_WHERE      TYPE RSDSWHERE,
    LT_WHERE      TYPE RSDS_WHERE_TAB,
    LT_DATA       TYPE REF TO DATA,
    LS_DATA       TYPE REF TO DATA,
    LS_KEYFIELD   TYPE GTY_KEY_FIELDS,
    LW_FIRST_CLAU TYPE XMARK.

  FIELD-SYMBOLS:
    <LF_VALUE>        TYPE ANY,
    <LF_DATA_STR>     TYPE ANY.

  IF  T_TABLE_CURRENT IS NOT INITIAL.
**   Create structure of 3 tables insert, update, delete
*    CREATE DATA LT_DATA LIKE T_TABLE_CURRENT.
*    ASSIGN LT_DATA->* TO <GFT_DATA_TABLE>.
*   Create structure data
    CREATE DATA LS_DATA LIKE LINE OF T_TABLE_CURRENT.
    ASSIGN LS_DATA->* TO <LF_DATA_STR>.
**   Get data
*    <GFT_DATA_TABLE> = T_TABLE_CURRENT.
*  ELSE.
*    RAISE NO_DATA.
  ENDIF.

  CLEAR: GT_WHERE_CLAUSES[].
  LW_FIRST_CLAU = 'X'.
* Build where clause for each record
  LOOP AT T_TABLE_CURRENT INTO <LF_DATA_STR>.
    CLEAR: GT_SELECTION[].
    LS_RANGE-SIGN           = 'I'.
    LS_RANGE-OPTION         = 'EQ'.
    LS_SELECTION-LOG_COND   = 'AND'.          "Logical condition

*   Build expression for each key field
    LOOP AT GT_KEYFIELDS INTO LS_KEYFIELD.
      CLEAR LS_SELECTION-RANGES_TAB[].
      LS_SELECTION-FIELD_NAME = LS_KEYFIELD-FIELDNAME.
*     Get value of key
      ASSIGN COMPONENT LS_KEYFIELD-FIELDNAME OF STRUCTURE
        <LF_DATA_STR> TO <LF_VALUE>.
      LS_RANGE-LOW            = <LF_VALUE>.
      APPEND LS_RANGE     TO LS_SELECTION-RANGES_TAB.
      APPEND LS_SELECTION TO GT_SELECTION.
    ENDLOOP.
*   If no selection, continue key
    IF GT_SELECTION[] IS INITIAL.
      CONTINUE.
    ENDIF.
    IF LW_FIRST_CLAU IS INITIAL.
      LS_WHERE = 'OR'.
      APPEND LS_WHERE TO GT_WHERE_CLAUSES.
    ELSE.
      CLEAR: LW_FIRST_CLAU.
    ENDIF.
    LS_WHERE = '('.
    APPEND LS_WHERE TO GT_WHERE_CLAUSES.

*   Generate where clause
    CALL FUNCTION 'ADSPC_CREATE_WHERE_CLAUSE'
      TABLES
        SELECTION_TAB = GT_SELECTION          "Range table
        WHERE_CLAUSE  = LT_WHERE.             "Where clause
    IF SY-SUBRC = 0.
      APPEND LINES OF LT_WHERE TO GT_WHERE_CLAUSES.

*     Add ')' mark at the end
      CLEAR LS_WHERE.
      LS_WHERE = ')'.
      APPEND LS_WHERE TO GT_WHERE_CLAUSES.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " BUILD_WHERE_CLAUSE

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_BY_CLAUSE
*&---------------------------------------------------------------------*
*       Get data by clause
*----------------------------------------------------------------------*
FORM GET_DATA_BY_CLAUSE
  CHANGING T_TABLE_ORIGINAL TYPE ANY TABLE.

  CALL FUNCTION 'ZFM_DATTAB_GET'
    EXPORTING
      I_TABLE         = GW_TABNAME
      T_WHERE_CLAUSES = GT_WHERE_CLAUSES
    IMPORTING
      T_TABLE_DATA    = T_TABLE_ORIGINAL.

*  DATA:
*    LW_WHERE_CLAUSE TYPE STRING,
*    LS_WHERE        TYPE RSDSWHERE.
*
** Init
*  CLEAR T_TABLE_ORIGINAL.
** Check where clause
*  IF GT_WHERE_CLAUSES IS NOT INITIAL.
**   Make where clause
*    CLEAR:  LW_WHERE_CLAUSE.
*    LOOP AT GT_WHERE_CLAUSES INTO LS_WHERE.
*      CONCATENATE LW_WHERE_CLAUSE
*                  LS_WHERE
*             INTO LW_WHERE_CLAUSE SEPARATED BY SPACE.
*    ENDLOOP.
*
**   Get data from database
*    SELECT *
*      INTO TABLE T_TABLE_ORIGINAL
*      FROM (GW_TABNAME)
*      WHERE (LW_WHERE_CLAUSE).
*  ELSE.
**   Get data from database
*    SELECT *
*      INTO TABLE T_TABLE_ORIGINAL
*      FROM (GW_TABNAME).
*  ENDIF.
ENDFORM.                    "GET_DATA_BY_CLAUSE


*&---------------------------------------------------------------------*
*&      Form  GET_ORIGINAL_DATA_JOININTAB
*&---------------------------------------------------------------------*
*       Build where clause to select
*----------------------------------------------------------------------*
FORM GET_ORIGINAL_DATA_JOININTAB
  USING T_TABLE_CURRENT   TYPE ANY TABLE
  CHANGING T_TABLE_ORIGINAL TYPE ANY TABLE.

  DATA:
    LS_WHERE      TYPE RSDSWHERE,
    LT_WHERE      TYPE RSDS_WHERE_TAB,
    LT_DATA       TYPE REF TO DATA,
    LS_DATA       TYPE REF TO DATA,
    LS_KEYFIELD   TYPE GTY_KEY_FIELDS,
    LW_INTAB_F    TYPE CHAR61,
    LW_WHERE_STR  TYPE STRING.

  FIELD-SYMBOLS:
    <LF_VALUE>        TYPE ANY,
    <LF_DATA_STR>     TYPE ANY.

  IF  T_TABLE_CURRENT IS NOT INITIAL.
    CREATE DATA LS_DATA LIKE LINE OF T_TABLE_CURRENT.
    ASSIGN LS_DATA->* TO <LF_DATA_STR>.
  ENDIF.

* Build expression for each key field
  LOOP AT GT_KEYFIELDS INTO LS_KEYFIELD.
    CLEAR LS_WHERE.
    CONCATENATE 'T_TABLE_CURRENT-'
                LS_KEYFIELD-FIELDNAME
           INTO LW_INTAB_F.
    CONCATENATE LS_KEYFIELD-FIELDNAME '=' LW_INTAB_F
           INTO LS_WHERE SEPARATED BY SPACE.
    APPEND LS_WHERE TO LT_WHERE.
  ENDLOOP.

  CONCATENATE LINES OF LT_WHERE INTO LW_WHERE_STR SEPARATED BY ' AND '.

* Get data from database
  SELECT *
    INTO TABLE T_TABLE_ORIGINAL
    FROM (GW_TABNAME)
     FOR ALL ENTRIES IN T_TABLE_CURRENT
    WHERE (LW_WHERE_STR).

ENDFORM.                    " GET_ORIGINAL_DATA_JOININTAB

*&---------------------------------------------------------------------*
*&      Form  CHECK_PARAMETERS
*&---------------------------------------------------------------------*
*       Check input parameter
*----------------------------------------------------------------------*
FORM CHECK_PARAMETERS
  USING
    I_STRUCTURE       TYPE  TABNAME
    T_FIELDCAT        TYPE  LVC_T_FCAT
    T_TABLE_CHANGED   TYPE  ANY TABLE
    T_TABLE_ORIGINAL  TYPE  ANY TABLE
    I_GET_ORG_DATA    TYPE  XMARK.

  PERFORM CHECK_STRUCTURE USING I_STRUCTURE T_FIELDCAT.

  IF T_TABLE_CHANGED IS INITIAL AND T_TABLE_ORIGINAL IS INITIAL.
    RAISE NO_DATA.
  ENDIF.

  IF  T_TABLE_ORIGINAL IS NOT INITIAL
  AND I_GET_ORG_DATA IS NOT INITIAL.
    RAISE CONFLICT_ORIGINAL_DATA.
  ENDIF.
ENDFORM.    "CHECK_PARAMETERS

*&---------------------------------------------------------------------*
*&      Form  CHECK_STRUCTURE
*&---------------------------------------------------------------------*
*       Check structure info
*----------------------------------------------------------------------*
*      -->I_STRUCTURE  text
*      -->T_FIELDCAT   text
*----------------------------------------------------------------------*
FORM CHECK_STRUCTURE
  USING I_STRUCTURE       TYPE  TABNAME
        T_FIELDCAT        TYPE  LVC_T_FCAT.

  IF I_STRUCTURE IS INITIAL AND T_FIELDCAT[] IS INITIAL.
    RAISE NO_STRUCTURE.
  ELSEIF I_STRUCTURE IS NOT INITIAL AND T_FIELDCAT[] IS NOT INITIAL.
    RAISE CONFLICT_STRUCTURE.
  ENDIF.

ENDFORM.                    "CHECK_STRUCTURE
*&---------------------------------------------------------------------*
*&      Form  GET_FIELDCAT
*&---------------------------------------------------------------------*
*       Get field category
*----------------------------------------------------------------------*
*      -->I_STRUCTURE  text
*      -->T_FIELDCAT   text
*----------------------------------------------------------------------*
FORM GET_FIELDCAT
  USING I_STRUCTURE           TYPE  TABNAME
        T_FIELDCAT            TYPE  LVC_T_FCAT.

  DATA:
    LS_KEYFIELD               TYPE GTY_KEY_FIELDS.

  FIELD-SYMBOLS:
   <LF_FIELDCAT>              TYPE  LVC_S_FCAT.

  CLEAR: GT_KEYFIELDS[].
* Get field category
  IF T_FIELDCAT[] IS NOT INITIAL.
    READ TABLE T_FIELDCAT INDEX 1 ASSIGNING <LF_FIELDCAT>.
    IF <LF_FIELDCAT>-TABNAME IS INITIAL.
      RAISE NO_STRUCTURE.
    ELSE.
*     Get table name and field category
      GW_TABNAME = <LF_FIELDCAT>-TABNAME.
      GT_FIELDCAT[] = T_FIELDCAT[].
    ENDIF.
  ELSEIF I_STRUCTURE IS NOT INITIAL.
    CLEAR: GT_KEYFIELDS[], GT_FIELDCAT[].
*   Get table name and field category
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME       = I_STRUCTURE
        I_INTERNAL_TABNAME     = I_STRUCTURE
      CHANGING
        CT_FIELDCAT            = GT_FIELDCAT
      EXCEPTIONS
        INCONSISTENT_INTERFACE = 1
        PROGRAM_ERROR          = 2
        OTHERS                 = 3.
    IF SY-SUBRC <> 0.
      RAISE NO_STRUCTURE.
    ENDIF.
    GW_TABNAME = I_STRUCTURE.
  ENDIF.

* Get all key fields
  LOOP AT GT_FIELDCAT ASSIGNING <LF_FIELDCAT>.
    IF <LF_FIELDCAT>-KEY = 'X'.
      LS_KEYFIELD-TABNAME   = <LF_FIELDCAT>-TABNAME.
      LS_KEYFIELD-FIELDNAME = <LF_FIELDCAT>-FIELDNAME.
      APPEND LS_KEYFIELD TO GT_KEYFIELDS.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "GET_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  CREATE_TABLE_WITH_KEYS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_STRUCTURE       text
*      -->T_FIELDCAT        text
*      -->T_TABLE_CHANGED   text
*      -->T_TABLE_ORIGINAL  text
*      -->I_GET_ORG_DATA    text
*----------------------------------------------------------------------*
FORM CREATE_TABLE_WITH_KEYS.
  DATA:
    LREF_DATA     TYPE REF TO DATA,
    LREF_DATA2    TYPE REF TO DATA.

  CALL FUNCTION 'ZFM_DATTAB_BUILD_WITH_KEYS'
    EXPORTING
      I_TABNAME      = GW_TABNAME
    IMPORTING
      E_REF_TABDATA  = LREF_DATA
      E_REF_TABDATA2 = LREF_DATA2
    CHANGING
      T_FIELDCAT     = GT_FIELDCAT.

  ASSIGN LREF_DATA->* TO <GFT_DATA_ORG>.
  ASSIGN LREF_DATA2->* TO <GFT_DATA_TABLE>.

*  DATA:
*    LT_KEYS     TYPE TABLE OF FIELDNAME,
*    LS_KEYFIELD TYPE GTY_KEY_FIELDS,
*    LT_DATA     TYPE REF TO DATA.
*
*  CLEAR LT_KEYS.
*  LOOP AT GT_KEYFIELDS INTO LS_KEYFIELD.
*    APPEND LS_KEYFIELD-FIELDNAME TO LT_KEYS.
*  ENDLOOP.
*
*  CREATE DATA LT_DATA TYPE STANDARD TABLE OF
*         (GW_TABNAME) WITH KEY (LT_KEYS).
*  ASSIGN LT_DATA->* TO <GFT_DATA_ORG>.
*  CREATE DATA LT_DATA TYPE STANDARD TABLE OF
*         (GW_TABNAME) WITH KEY (LT_KEYS).
*  ASSIGN LT_DATA->* TO <GFT_DATA_TABLE>.

ENDFORM.    "CREATE_TABLE_WITH_KEYS

*&---------------------------------------------------------------------*
*&      Form  GET_ORG_DATA
*&---------------------------------------------------------------------*
*       Get original data if need
*----------------------------------------------------------------------*
FORM GET_ORG_DATA
  USING
    T_TABLE_CHANGED   TYPE  ANY TABLE
    T_TABLE_ORIGINAL  TYPE  ANY TABLE
    I_GET_ORG_DATA    TYPE  XMARK.

  DATA: LT_DATA       TYPE REF TO DATA,
        LS_DATA       TYPE REF TO DATA.
  FIELD-SYMBOLS:
    <LF_DATA_STR>     TYPE ANY.

* Create structure for current data
  <GFT_DATA_TABLE> = T_TABLE_CHANGED.
  <GFT_DATA_ORG> = T_TABLE_ORIGINAL.

  IF  T_TABLE_ORIGINAL IS INITIAL
  AND I_GET_ORG_DATA IS NOT INITIAL.
*   Manually get data
    CALL FUNCTION 'ZFM_DATA_ORIGINAL_GET'
      EXPORTING
        T_TABLE_CURRENT    = T_TABLE_CHANGED
        T_FIELDCAT         = GT_FIELDCAT
      IMPORTING
        T_TABLE_ORIGINAL   = <GFT_DATA_ORG>
      EXCEPTIONS
        NO_STRUCTURE       = 1
        CONFLICT_STRUCTURE = 2
        NO_DATA            = 3
        OTHERS             = 4.
  ENDIF.
ENDFORM.    "GET_ORG_DATA

*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA
*&---------------------------------------------------------------------*
*       Modify data
*----------------------------------------------------------------------*
FORM MODIFY_DATA
  USING I_DEL_FIELD           TYPE FIELDNAME
        LPW_ASSIGN_RQ         TYPE XMARK
  CHANGING LPT_TABLE_DELETE   TYPE TABLE
           LPT_TABLE_UPDATE   TYPE TABLE
           LPT_TABLE_INSERT   TYPE TABLE.
  DATA: LT_DATA               TYPE REF TO DATA,
        LS_DATA               TYPE REF TO DATA,
        LW_VALID              TYPE C,
        LW_USING_KEY          TYPE CHAR256.
  FIELD-SYMBOLS:
    <LF_VALUE>                TYPE ANY,
    <LF_DATA_STR>             TYPE ANY,
    <LF_DATA_ORG>             TYPE ANY,
    <LFT_DATA_INSERT>         TYPE TABLE,
    <LFT_DATA_UPDATE>         TYPE TABLE,
    <LFT_DATA_DELETE>         TYPE TABLE.

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

* Get change info
  LOOP AT <GFT_DATA_TABLE> ASSIGNING <LF_DATA_STR>.
*   Find old record
    READ TABLE <GFT_DATA_ORG> FROM <LF_DATA_STR>
      ASSIGNING <LF_DATA_ORG>.
    IF SY-SUBRC IS NOT INITIAL.
*     Not found old record, will insert
      APPEND <LF_DATA_STR> TO <LFT_DATA_INSERT>.
    ELSE.
*     Found, check data change
      IF <LF_DATA_STR> <> <LF_DATA_ORG>.
*       Changed, will update
        APPEND <LF_DATA_STR> TO <LFT_DATA_UPDATE>.
      ENDIF.
*     Found, delete to next loop
      DELETE TABLE <GFT_DATA_ORG> FROM <LF_DATA_ORG>.
    ENDIF.
  ENDLOOP.

* Get all remain deleted records
  IF I_DEL_FIELD IS INITIAL.
    APPEND LINES OF <GFT_DATA_ORG> TO <LFT_DATA_DELETE>.
  ELSE.
    LOOP AT <GFT_DATA_ORG> ASSIGNING <LF_DATA_STR>.
      ASSIGN COMPONENT I_DEL_FIELD OF STRUCTURE <LF_DATA_STR>
        TO <LF_VALUE>.
      IF SY-SUBRC IS NOT INITIAL.
        RAISE DEL_FIELD_NOT_EXISTS.
      ELSE.
        <LF_VALUE> = 'X'.
      ENDIF.
    ENDLOOP.
    APPEND LINES OF <GFT_DATA_ORG> TO <LFT_DATA_UPDATE>.
  ENDIF.

* Delete in database
  IF <LFT_DATA_DELETE> IS NOT INITIAL.
    TRY.
        DELETE (GW_TABNAME) FROM TABLE <LFT_DATA_DELETE>.
      CATCH CX_SY_OPEN_SQL_DB.
        RAISE DELETE_ERROR.
    ENDTRY.
    IF SY-SUBRC IS NOT INITIAL.
      RAISE DELETE_ERROR.
    ENDIF.
  ENDIF.

* Update in database
  IF <LFT_DATA_UPDATE> IS NOT INITIAL.
    TRY.
        UPDATE (GW_TABNAME) FROM TABLE <LFT_DATA_UPDATE>.
      CATCH CX_SY_OPEN_SQL_DB.
        RAISE UPDATE_ERROR.
    ENDTRY.
    IF SY-SUBRC IS NOT INITIAL.
      RAISE UPDATE_ERROR.
    ENDIF.
  ENDIF.
* Insert in database
  IF <LFT_DATA_INSERT> IS NOT INITIAL.
    TRY.
        INSERT (GW_TABNAME) FROM TABLE <LFT_DATA_INSERT>.
      CATCH CX_SY_OPEN_SQL_DB.
        RAISE UPDATE_ERROR.
    ENDTRY.
    IF SY-SUBRC IS NOT INITIAL.
      RAISE UPDATE_ERROR.
    ENDIF.
  ENDIF.

  IF LPT_TABLE_DELETE IS REQUESTED.
    LPT_TABLE_DELETE          = <LFT_DATA_DELETE>.
  ENDIF.

  IF LPT_TABLE_UPDATE IS REQUESTED.
    LPT_TABLE_UPDATE          = <LFT_DATA_UPDATE>.
  ENDIF.

  IF LPT_TABLE_INSERT IS REQUESTED.
    LPT_TABLE_INSERT          = <LFT_DATA_INSERT>.
  ENDIF.

  IF LPW_ASSIGN_RQ IS NOT INITIAL.
    PERFORM 9999_ASSIGN_ENTRIES_TO_RQ
      USING <LFT_DATA_DELETE>
            <LFT_DATA_UPDATE>
            <LFT_DATA_INSERT>.
  ENDIF.
ENDFORM.                    "MODIFY_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA_TYPE
  USING  LPW_DATATYPE TYPE DATATYPE_D.

* Get all data type
  PERFORM GET_ALL_DATATYPE.

  IF LPW_DATATYPE NOT IN GTR_DATATYPE.
    RAISE NOT_FOUND_TYPE.
  ENDIF.


ENDFORM.                    "GET_DATA_TYPE

*&---------------------------------------------------------------------*
*&      Form  GET_ALL_DATATYPE
*&---------------------------------------------------------------------*
*       Get all datatype
*----------------------------------------------------------------------*
FORM GET_ALL_DATATYPE.
  DATA:
    LR_DATATYPE   LIKE LINE OF GTR_DATATYPE.

* Check type is init
  CHECK GTR_DATATYPE[] IS INITIAL.

  LR_DATATYPE-SIGN   = 'I'.
  LR_DATATYPE-OPTION = 'EQ'.
  LR_DATATYPE-LOW    = 'ACCP'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'CHAR'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'CLNT'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'CUKY'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'CURR'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'DATS'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'DEC'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'FLTP'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'INT1'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'INT2'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'INT4'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'LANG'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'LCHR'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'LRAW'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'NUMC'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'PREC'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'QUAN'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'RAW'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'RSTR'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'SSTR'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'STRG'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'TIMS'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'VARC'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
  LR_DATATYPE-LOW    = 'UNIT'.
  APPEND LR_DATATYPE TO GTR_DATATYPE.
ENDFORM.                    "GET_ALL_DATATYPE

*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA_TYPE
*&---------------------------------------------------------------------*
*       Check data type
*----------------------------------------------------------------------*
*      --> LPW_DATATYPE  data type
*      <-- LPW_ERROR     error
*----------------------------------------------------------------------*
FORM CHECK_DATA_TYPE
  USING    LPW_DATATYPE TYPE DATATYPE_D
           LPW_VALUE    TYPE ANY
  CHANGING LPW_ERROR    TYPE XMARK.

  CLEAR LPW_ERROR.
  CHECK LPW_VALUE IS NOT INITIAL.

  CASE LPW_DATATYPE.
    WHEN 'DATS'.
      CALL FUNCTION 'DATE_CONV_EXT_TO_INT'
        EXPORTING
          I_DATE_EXT = LPW_VALUE
        EXCEPTIONS
          ERROR      = 1
          OTHERS     = 2.
      IF SY-SUBRC <> 0.
        LPW_ERROR = 'X'.
      ENDIF.

    WHEN 'NUMC'.
      CALL FUNCTION 'IF_CA_MAKE_STRING_NUMERICAL'
        EXPORTING
          INPUT_STRING  = LPW_VALUE
        EXCEPTIONS
          NOT_NUMERICAL = 1
          OTHERS        = 2.
      IF SY-SUBRC <> 0.
        LPW_ERROR = 'X'.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " CHECK_DATA_TYPE

*&---------------------------------------------------------------------*
*&      Form  PREPARE_TABLE_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPT_RSDSTABS    Table list
*      <--LPT_RSDSFIELDS  Selection Fields
*      <--LPT_EXCL_FIELDS Exclude fields
*----------------------------------------------------------------------*
FORM PREPARE_TABLE_INFO
  USING     LPW_TABLE         TYPE TABNAME
            LPW_MAXSELECT     TYPE I
  CHANGING  LPT_RSDSTABS      TYPE RSDSTABS_T
            LPT_RSDSFIELDS    TYPE RSDSFIELDS_T
            LPT_EXCL_FIELDS   TYPE RSDSFIELDS_T.
  DATA:
    LS_RSDSTABS     TYPE RSDSTABS,
    LS_RSDSFIELDS   TYPE RSDSFIELDS,
    LT_FIELDCAT     TYPE LVC_T_FCAT ,
    LS_FIELDCAT     TYPE LVC_S_FCAT,
    LS_RSDSFCODE    TYPE RSDSFCODE.

  CHECK LPT_RSDSTABS IS INITIAL.

* Get table name
  LS_RSDSTABS-PRIM_TAB = LPW_TABLE.
  APPEND LS_RSDSTABS TO LPT_RSDSTABS.

* Get structure of table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = LPW_TABLE
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
    IF LPW_MAXSELECT > 0 AND LS_FIELDCAT-COL_POS > LPW_MAXSELECT.
      APPEND LS_RSDSFIELDS TO LPT_EXCL_FIELDS.
    ELSE.
      APPEND LS_RSDSFIELDS TO LPT_RSDSFIELDS.
    ENDIF.
  ENDLOOP.

* Display screen for select
  CLEAR: GT_RSDSFCODE[].
  LS_RSDSFCODE-FCODE  = 'BACK'.
  LS_RSDSFCODE-FORM   = 'LEAVE'.
  APPEND LS_RSDSFCODE TO GT_RSDSFCODE.
  LS_RSDSFCODE-FCODE  = 'EXIT'.
  APPEND LS_RSDSFCODE TO GT_RSDSFCODE.
  LS_RSDSFCODE-FCODE  = 'DCAN'.
  APPEND LS_RSDSFCODE TO GT_RSDSFCODE.
ENDFORM.                    " PREPARE_TABLE_INFO

*&---------------------------------------------------------------------*
*&      Form  9999_STANDARD_COND_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_REPID       Call program
*      -->LPS_RECORD      Checking Record
*      <--LPW_COND_VALUE  Condition value
*----------------------------------------------------------------------*
FORM 9999_STANDARD_COND_VALUE
  USING   LPW_REPID           TYPE REPID
          LPS_RECORD          TYPE ANY
 CHANGING LPW_COND_VALUE      TYPE ANY.

  DATA:
    LW_FIELDNAME              TYPE FIELDNAME.
  FIELD-SYMBOLS:
    <LF_FIELD_VALUE>          TYPE ANY.       "New Field Value

* Field in current structure
  IF LPW_COND_VALUE(1) = '$'.
    LW_FIELDNAME = LPW_COND_VALUE+1.
    ASSIGN COMPONENT LW_FIELDNAME OF STRUCTURE LPS_RECORD
      TO <LF_FIELD_VALUE>.
    IF SY-SUBRC IS INITIAL.
      LPW_COND_VALUE = <LF_FIELD_VALUE>.
    ELSE.
      MESSAGE A011(ZMS_LIB_PROG) WITH LW_FIELDNAME.
    ENDIF.
  ENDIF.

* Field in call program
  IF LPW_COND_VALUE(1) = '&'.
    LW_FIELDNAME = '(' && LPW_REPID && ')' && LPW_COND_VALUE+1.
    ASSIGN (LW_FIELDNAME) TO <LF_FIELD_VALUE>.
    IF SY-SUBRC IS INITIAL.
      LPW_COND_VALUE = <LF_FIELD_VALUE>.
    ELSE.
      MESSAGE A012(ZMS_LIB_PROG) WITH LW_FIELDNAME LPW_REPID.
    ENDIF.
  ENDIF.

ENDFORM.                    " 9999_STANDARD_COND_VALUE

*&---------------------------------------------------------------------*
*&      Form  9999_ASSIGN_ENTRIES_TO_RQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPT_TABLE_DELETE  text
*      -->LPT_TABLE_UPDATE  text
*      -->LPT_TABLE_INSERT  text
*----------------------------------------------------------------------*
FORM 9999_ASSIGN_ENTRIES_TO_RQ
  USING    LPT_TABLE_DELETE   TYPE TABLE
           LPT_TABLE_UPDATE   TYPE TABLE
           LPT_TABLE_INSERT   TYPE TABLE.
  DATA:
    LS_KEY                    TYPE E071K,
    LS_OBJ                    TYPE KO200,
    LS_ERROR                  TYPE IWERRORMSG,
    LS_FIELDCAT               TYPE LVC_S_FCAT,
    LW_LENGTH                 TYPE I,
    LW_KEY_LEN                TYPE I,
    LW_KEY                    TYPE CHAR50,
    LT_KEY                    TYPE APB_LPD_T_E071K,
    LT_OBJ                    TYPE /SAPCND/T_KO200.
  FIELD-SYMBOLS:
    <LF_KEY>                  TYPE ANY,
    <LF_ENTRY>                TYPE ANY.

  APPEND LINES OF LPT_TABLE_DELETE TO LPT_TABLE_INSERT.
  APPEND LINES OF LPT_TABLE_UPDATE TO LPT_TABLE_INSERT.

  LS_KEY-PGMID                = 'R3TR'.
  LS_KEY-OBJECT               = 'TABU'.
  LS_KEY-OBJNAME              = GW_TABNAME.
  LS_KEY-MASTERNAME           = LS_KEY-OBJNAME.
  LS_KEY-MASTERTYPE           = LS_KEY-OBJECT.

  MOVE-CORRESPONDING LS_KEY TO LS_OBJ.
  LS_OBJ-OBJFUNC              = 'K'.
  LS_OBJ-OBJ_NAME             = LS_KEY-OBJNAME.
  APPEND LS_OBJ TO LT_OBJ.

  LOOP AT LPT_TABLE_INSERT ASSIGNING <LF_ENTRY>.
    CLEAR: LS_KEY-TABKEY, LW_LENGTH.

    LOOP AT GT_FIELDCAT INTO LS_FIELDCAT
      WHERE KEY IS NOT INITIAL.
      ASSIGN COMPONENT LS_FIELDCAT-FIELDNAME OF STRUCTURE <LF_ENTRY>
        TO <LF_KEY>.
      IF SY-SUBRC IS INITIAL.
        IF LS_FIELDCAT-FIELDNAME = 'MANDT'
        OR LS_FIELDCAT-DATATYPE	 = 'CLNT'.
          <LF_KEY> = SY-MANDT.
        ENDIF.

        IF LS_FIELDCAT-INTTYPE = 'I'.
          CONCATENATE LS_KEY-TABKEY(LW_LENGTH) '*'
            INTO LS_KEY-TABKEY RESPECTING BLANKS.
          LW_LENGTH           = LW_LENGTH + 1.
          EXIT.
        ELSE.
          LW_KEY_LEN = LS_FIELDCAT-INTLEN.
          LW_KEY = <LF_KEY>.
          CONDENSE LW_KEY.
          IF LW_LENGTH IS INITIAL.
            LS_KEY-TABKEY = LW_KEY(LS_FIELDCAT-INTLEN).
          ELSE.
            CONCATENATE LS_KEY-TABKEY(LW_LENGTH)
                        LW_KEY(LW_KEY_LEN)
                   INTO LS_KEY-TABKEY RESPECTING BLANKS.
          ENDIF.
          LW_LENGTH             = LW_LENGTH + LS_FIELDCAT-INTLEN.
        ENDIF.
      ENDIF.
    ENDLOOP.

    APPEND LS_KEY TO LT_KEY.
  ENDLOOP.

  SORT LT_KEY BY TABKEY.
  DELETE ADJACENT DUPLICATES FROM LT_KEY COMPARING TABKEY.
  IF LT_KEY[] IS NOT INITIAL.
    IF GW_TAB_RQ IS INITIAL.
      CALL FUNCTION 'IW_C_APPEND_OBJECTS_TO_REQUEST'
        IMPORTING
          ERROR_MSG       = LS_ERROR
          TRANSPORT_ORDER = GW_TAB_RQ
        TABLES
          OBJECTS         = LT_OBJ
          KEYS            = LT_KEY.
    ELSE.
      CALL FUNCTION 'TR_OBJECTS_INSERT'
        EXPORTING
          WI_ORDER                = GW_TAB_RQ
        IMPORTING
          WE_ORDER                = GW_TAB_RQ
        TABLES
          WT_KO200                = LT_OBJ
          WT_E071K                = LT_KEY
        EXCEPTIONS
          CANCEL_EDIT_OTHER_ERROR = 1
          SHOW_ONLY_OTHER_ERROR   = 2
          OTHERS                  = 3.
    ENDIF.
  ENDIF.

ENDFORM.                    " 9999_ASSIGN_ENTRIES_TO_RQ

*&---------------------------------------------------------------------*
*&      Form  UNESCAPE_AMP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_SYMBOL_STR   Special symbol string
*      -->LPW_SYMBOL_NUM   Special symbol unicode number
*      <--LPW_HTML         HTML document
*----------------------------------------------------------------------*
FORM UNESCAPE_AMP
  USING   LPW_SYMBOL_STR  TYPE STRING
          LPW_SYMBOL_NUM  TYPE I
 CHANGING LPW_HTML        TYPE STRING.

  DATA:
    LW_PATTERN                TYPE STRING,
    LW_REPLACE                TYPE STRING.

* Check document has pattern
  CONCATENATE '*' LPW_SYMBOL_STR '*' INTO LW_PATTERN.
  IF LPW_HTML CP LW_PATTERN.
    TRY.
        LW_REPLACE = CL_ABAP_CONV_IN_CE=>UCCPI( LPW_SYMBOL_NUM ).
      CATCH CX_ROOT.
        LW_REPLACE = '#'.
    ENDTRY.
    REPLACE ALL OCCURRENCES OF LPW_SYMBOL_STR
      IN LPW_HTML WITH LW_REPLACE.
  ENDIF.

ENDFORM.                    " UNESCAPE_AMP
