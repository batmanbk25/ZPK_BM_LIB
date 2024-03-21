FUNCTION ZFM_DATTAB_FREE_SELECTION.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_TABLE) TYPE  TABNAME
*"     REFERENCE(I_MAXSELECT) TYPE  I DEFAULT 20
*"     REFERENCE(I_KIND) DEFAULT 'T'
*"  EXPORTING
*"     REFERENCE(T_WHERE_CLAUSES) TYPE  TT_RSDSWHERE
*"  CHANGING
*"     REFERENCE(C_SELID) TYPE  DYNSELID OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"--------------------------------------------------------------------
DATA:
    LS_RSDSTABS     TYPE RSDSTABS,
    LS_RSDSFIELDS   TYPE RSDSFIELDS,
    LT_FIELDCAT     TYPE LVC_T_FCAT ,
    LS_FIELDCAT     TYPE LVC_S_FCAT,
    LT_RSDS_TRANGE  TYPE RSDS_TRANGE,
    LT_RSDS_TWHERE  TYPE RSDS_TWHERE,
    LS_RSDS_TWHERE  LIKE LINE OF LT_RSDS_TWHERE.

  CLEAR: T_WHERE_CLAUSES.
  PERFORM PREPARE_TABLE_INFO
    USING I_TABLE
          I_MAXSELECT
    CHANGING  GT_RSDSTABS
              GT_RSDSFIELDS
              GT_EXCL_FIELDS.

  IF C_SELID IS INITIAL.
*   Init dynamic selection
    CALL FUNCTION 'FREE_SELECTIONS_INIT'
      EXPORTING
        KIND                     = I_KIND
        ALV                      = 'X'
        FIELD_RANGES_INT         = GT_RSDS_TRANGE
      IMPORTING
        SELECTION_ID             = C_SELID
      TABLES
        TABLES_TAB               = GT_RSDSTABS
        FIELDS_TAB               = GT_RSDSFIELDS
        FIELDS_NOT_SELECTED      = GT_EXCL_FIELDS
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
  ENDIF.

  CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
    EXPORTING
      SELECTION_ID        = C_SELID
      ALV                 = 'X'
      TITLE               = 'Selection'
      STATUS              = 1
    IMPORTING
      WHERE_CLAUSES       = LT_RSDS_TWHERE
      FIELD_RANGES        = GT_RSDS_TRANGE
    TABLES
      FIELDS_TAB          = GT_RSDSFIELDS
      FCODE_TAB           = GT_RSDSFCODE
      FIELDS_NOT_SELECTED = GT_EXCL_FIELDS
    EXCEPTIONS
      INTERNAL_ERROR      = 1
      NO_ACTION           = 2
      SELID_NOT_FOUND     = 3
      ILLEGAL_STATUS      = 4
      OTHERS              = 5.
  IF SY-SUBRC = 0.
    IF LT_RSDS_TWHERE[] IS NOT INITIAL.
      READ TABLE LT_RSDS_TWHERE INDEX 1 INTO LS_RSDS_TWHERE.
      T_WHERE_CLAUSES = LS_RSDS_TWHERE-WHERE_TAB.
    ENDIF.
  ELSE.
    RAISE ERROR.
  ENDIF.





ENDFUNCTION.
