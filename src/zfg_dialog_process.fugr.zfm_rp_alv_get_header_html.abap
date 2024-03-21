FUNCTION ZFM_RP_ALV_GET_HEADER_HTML.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_REPORT) TYPE  PROGRAMM DEFAULT SY-CPROG
*"     REFERENCE(I_TABNAME) TYPE  TABNAME OPTIONAL
*"     REFERENCE(I_RP_DATA)
*"     REFERENCE(I_TEMPLATE) TYPE  XMARK OPTIONAL
*"     REFERENCE(T_ALV_LAYOUT) TYPE  ZTT_ALV_LAYOUT OPTIONAL
*"  EXPORTING
*"     REFERENCE(T_ALV_HEADER) TYPE  ZTT_ALV_HEADER
*"     REFERENCE(E_HEIGHT) TYPE  INT4
*"     REFERENCE(E_LOGO) TYPE  ZST_BM_ALV_LOGO
*"----------------------------------------------------------------------
  DATA:
    LT_ALV_HDR                TYPE TABLE OF ZTB_BM_ALV_LAYO,
    LS_ALV_HDR                TYPE ZTB_BM_ALV_LAYO,
    LT_FIELDCAT               TYPE TABLE OF LVC_S_FCAT,
    LS_FIELDCAT               TYPE LVC_S_FCAT,
    LW_TABNAME                TYPE TABNAME,
    LS_ALV_HEADER             TYPE ZST_ALV_HEADER,
    LW_FULLNAME               TYPE TEXT60,
    LW_LINE                   TYPE I.
  FIELD-SYMBOLS:
    <LF_DATA>                 TYPE ANY,
    <LFT_ITEMS>               TYPE ANY TABLE.

* Get RP data structure type
  LW_TABNAME = I_TABNAME.
  IF LW_TABNAME IS INITIAL.
    DESCRIBE FIELD I_RP_DATA HELP-ID LW_TABNAME.
  ENDIF.

* Get fieldcat of report data to convert data to correct format
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME   = LW_TABNAME
      I_INTERNAL_TABNAME = LW_TABNAME
    CHANGING
      CT_FIELDCAT        = LT_FIELDCAT
    EXCEPTIONS
      OTHERS             = 3.
  SORT LT_FIELDCAT BY FIELDNAME.

* Get ALV layout
  LT_ALV_HDR = T_ALV_LAYOUT.
  IF LT_ALV_HDR IS INITIAL.
    SELECT *
      INTO TABLE LT_ALV_HDR
      FROM ZTB_BM_ALV_LAYO
     WHERE REPORT  = I_REPORT.
  ENDIF.
  DELETE LT_ALV_HDR WHERE IS_ITEM = 'X'.

* Get header HTML data
  SORT LT_ALV_HDR BY POSID.
  LOOP AT LT_ALV_HDR INTO LS_ALV_HDR
    WHERE TYP IS NOT INITIAL.
    CLEAR: LS_ALV_HEADER.

*   Export logo
    IF LS_ALV_HDR-TYP = GC_ALV_TYP_LOGO.
      CHECK E_LOGO IS INITIAL.
      E_LOGO-LOGO              = LS_ALV_HDR-HKEY.
      E_LOGO-WIDTH             = LS_ALV_HDR-COLS.
      CONDENSE E_LOGO-WIDTH.
      CONTINUE.
    ENDIF.

*   Set text type
    LS_ALV_HEADER-TYP = LS_ALV_HDR-TYP.

*   Get key content (for Selection Type)
    CONCATENATE '(' I_REPORT ')' LS_ALV_HDR-HKEY INTO LW_FULLNAME.
    ASSIGN (LW_FULLNAME) TO <LF_DATA>.
    IF SY-SUBRC IS INITIAL.
*     Dynamic key content: Get from variable of program
      LS_ALV_HEADER-KEY = <LF_DATA>.
    ELSE.
*     Static key content: Get from content in config
      LS_ALV_HEADER-KEY = LS_ALV_HDR-HKEY.
    ENDIF.

*   Convert Info text to correct format
    IF I_TEMPLATE IS INITIAL.
      READ TABLE LT_FIELDCAT INTO LS_FIELDCAT
        WITH KEY FIELDNAME = LS_ALV_HDR-FNAME BINARY SEARCH.
      IF SY-SUBRC IS INITIAL.
        CALL FUNCTION 'ZFM_DATA_VALUE2TEXT'
          EXPORTING
            I_FIELDCAT  = LS_FIELDCAT
            I_DATASTR   = I_RP_DATA
            I_FIELDNAME = LS_ALV_HDR-FNAME
          IMPORTING
            E_VALUET    = LS_ALV_HEADER-INFO.
      ENDIF.
    ELSE.
      LS_ALV_HEADER-INFO = '[' && LS_ALV_HDR-FNAME && ']'.
    ENDIF.
    CHECK LS_ALV_HEADER-INFO IS NOT INITIAL.

*   Get PREFIX content
    ASSIGN COMPONENT LS_ALV_HDR-PREFIX OF STRUCTURE I_RP_DATA
      TO <LF_DATA>.
    IF SY-SUBRC IS INITIAL.
      IF I_TEMPLATE IS INITIAL.
*       Dynamic key content: Get from variable of program
        LS_ALV_HDR-PREFIX = <LF_DATA>.
      ELSE.
*       Dynamic key content: Get from variable of program
        LS_ALV_HDR-PREFIX = '[' && LS_ALV_HDR-PREFIX && ']'.
      ENDIF.
    ENDIF.

*   Get SUFFIX content
    ASSIGN COMPONENT LS_ALV_HDR-SUFFIX OF STRUCTURE I_RP_DATA
      TO <LF_DATA>.
    IF SY-SUBRC IS INITIAL.
      IF I_TEMPLATE IS INITIAL.
*       Dynamic key content: Get from variable of program
        LS_ALV_HDR-SUFFIX = <LF_DATA>.
      ELSE.
*       Dynamic key content: Get from variable of program
        LS_ALV_HDR-SUFFIX = '[' && LS_ALV_HDR-SUFFIX && ']'.
      ENDIF.
    ENDIF.

*   Concatenate Info text
    CONCATENATE LS_ALV_HDR-PREFIX LS_ALV_HEADER-INFO LS_ALV_HDR-SUFFIX
      INTO LS_ALV_HEADER-INFO SEPARATED BY SPACE.

    CONDENSE: LS_ALV_HEADER-INFO.
    APPEND LS_ALV_HEADER TO T_ALV_HEADER.

*   Get height of text type
    CASE LS_ALV_HDR-TYP.
*     Heading
      WHEN 'H'.
        LW_LINE = STRLEN( LS_ALV_HEADER-INFO )
                  DIV GC_ALV_LINELENG_H + 1.
        E_HEIGHT = E_HEIGHT + GC_ALV_HEIGH_H * LW_LINE.
*     Italic text
      WHEN 'A'.
        LW_LINE = STRLEN( LS_ALV_HEADER-INFO )
                  DIV GC_ALV_LINELENG_A + 1.
        E_HEIGHT = E_HEIGHT + GC_ALV_HEIGH_A.
*     Selection
      WHEN 'S'.
        LW_LINE = STRLEN( LS_ALV_HEADER-INFO )
                  DIV GC_ALV_LINELENG_S + 1.
        E_HEIGHT = E_HEIGHT + GC_ALV_HEIGH_S.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.


ENDFUNCTION.
